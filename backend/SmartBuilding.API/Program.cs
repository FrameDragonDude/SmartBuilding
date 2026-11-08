using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure;
using SmartBuilding.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("SmartBuilding")
    ?? throw new InvalidOperationException("Missing SmartBuilding connection string.");

builder.Services.AddOpenApi();
builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy
    .AllowAnyOrigin()
    .AllowAnyHeader()
    .AllowAnyMethod()));
builder.Services.AddInfrastructure(connectionString);
var app = builder.Build();
app.UseCors();
if (app.Environment.IsDevelopment()) app.MapOpenApi();

// Ensure sample apartments, floors and data exist for all 8 buildings
await DatabaseSeeder.EnsureAllBuildingsSeededAsync(connectionString);


// 0. TÒA NHÀ (BUILDINGS)

app.MapGet("/api/buildings", async (IResidentRepository repository, CancellationToken token) =>
    Results.Ok(await repository.GetBuildingsAsync(token)));


// 1. CƯ DÂN & CĂN HỘ (RESIDENTS & APARTMENTS)

app.MapGet("/api/residents", async (
    string? search,
    string? status,
    string? contractType,
    string? buildingId,
    IResidentRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetListAsync(search, status, contractType, buildingId, token)));

app.MapGet("/api/residents/summary", async (
    string? buildingId,
    IResidentRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetMetricsAsync(buildingId, token)));

app.MapGet("/api/residents/{apartmentId}/detail", async (
    string apartmentId,
    IResidentRepository repository,
    CancellationToken token) =>
{
    var detail = await repository.GetDetailAsync(apartmentId, token);
    return detail is null ? Results.NotFound(new { message = $"Không tìm thấy thông tin căn hộ {apartmentId}" }) : Results.Ok(detail);
});

app.MapGet("/api/apartments", async (
    string? buildingId,
    IResidentRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetApartmentsAsync(buildingId, token)));

app.MapPost("/api/residents", async (
    CreateResidentRequest request,
    IResidentRepository repository,
    CancellationToken token) =>
{
    if (string.IsNullOrWhiteSpace(request.FullName))
        return Results.BadRequest(new { message = "Họ và tên không được để trống" });
    if (string.IsNullOrWhiteSpace(request.IdentityCardNumber))
        return Results.BadRequest(new { message = "Số CCCD/CMND không được để trống" });
    if (string.IsNullOrWhiteSpace(request.PhoneNumber))
        return Results.BadRequest(new { message = "Số điện thoại không được để trống" });
    if (string.IsNullOrWhiteSpace(request.ApartmentId))
        return Results.BadRequest(new { message = "Vui lòng chọn căn hộ" });

    try
    {
        var id = await repository.CreateResidentAsync(request, token);
        return Results.Created($"/api/residents/{request.ApartmentId}/detail", new { id, message = "Thêm mới cư dân thành công!" });
    }
    catch (Exception ex)
    {
        return Results.Problem(detail: ex.Message, statusCode: 500, title: "Lỗi thêm cư dân");
    }
});


// 2. BÃI XE & RFID (PARKING & VEHICLES)

app.MapGet("/api/parking", async (
    string? search,
    string? basement,
    string? slotType,
    bool? isOccupied,
    string? buildingId,
    IParkingRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetListAsync(search, basement, slotType, isOccupied, buildingId, token)));

app.MapGet("/api/parking/summary", async (
    string? buildingId,
    IParkingRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetMetricsAsync(buildingId, token)));

app.MapGet("/api/parking/{slotId}/detail", async (
    string slotId,
    IParkingRepository repository,
    CancellationToken token) =>
{
    var detail = await repository.GetDetailAsync(slotId, token);
    return detail is null ? Results.NotFound(new { message = $"Không tìm thấy vị trí đỗ {slotId}" }) : Results.Ok(detail);
});

app.MapPost("/api/parking/register", async (
    CreateVehicleRequest request,
    IParkingRepository repository,
    CancellationToken token) =>
{
    if (string.IsNullOrWhiteSpace(request.ResidentId))
        return Results.BadRequest(new { message = "Vui lòng chọn cư dân" });
    if (string.IsNullOrWhiteSpace(request.ApartmentId))
        return Results.BadRequest(new { message = "Vui lòng chọn căn hộ" });
    if (string.IsNullOrWhiteSpace(request.LicensePlate))
        return Results.BadRequest(new { message = "Biển số xe không được để trống" });
    if (string.IsNullOrWhiteSpace(request.RfidCardCode))
        return Results.BadRequest(new { message = "Mã thẻ RFID không được để trống" });

    try
    {
        var vehicleId = await repository.RegisterVehicleAsync(request, token);
        return Results.Created($"/api/parking/register/{vehicleId}", new { vehicleId, message = "Đăng ký xe & cấp thẻ RFID thành công!" });
    }
    catch (Exception ex)
    {
        return Results.Problem(detail: ex.Message, statusCode: 500, title: "Lỗi đăng ký xe");
    }
});

app.MapPost("/api/parking/{slotId}/release", async (
    string slotId,
    IParkingRepository repository,
    CancellationToken token) =>
{
    var success = await repository.ReleaseSlotAsync(slotId, token);
    return success
        ? Results.Ok(new { success = true, message = "Đã thu hồi thẻ và trả vị trí ô đỗ thành công!" })
        : Results.NotFound(new { success = false, message = "Không tìm thấy vị trí ô đỗ" });
});


// 3. HÓA ĐƠN & THU PHÍ (INVOICES & BILLING & RECONCILIATION)

app.MapGet("/api/invoices", async (
    string? search,
    string? filterTab,
    int? month,
    int? year,
    string? buildingId,
    IInvoiceRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetInvoicesAsync(search, filterTab, month, year, buildingId, token)));

app.MapGet("/api/invoices/summary", async (
    int? month,
    int? year,
    string? buildingId,
    IInvoiceRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetSummaryMetricsAsync(month, year, buildingId, token)));

app.MapGet("/api/invoices/pending-payments", async (
    IInvoiceRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetPendingPaymentsAsync(token)));

app.MapGet("/api/invoices/penalties", async (
    IInvoiceRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetPenaltiesAsync(token)));

app.MapGet("/api/invoices/revenue-structure", async (
    int? month,
    int? year,
    IInvoiceRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetRevenueStructureAsync(month, year, token)));

app.MapPost("/api/invoices/payments/{paymentId}/approve", async (
    string paymentId,
    IInvoiceRepository repository,
    CancellationToken token) =>
{
    var success = await repository.ApprovePaymentAsync(paymentId, token);
    return success
        ? Results.Ok(new { message = "Xác nhận đối soát thành công! Đã ghi nhận thanh toán vào hóa đơn." })
        : Results.NotFound(new { message = "Không tìm thấy giao dịch này." });
});

app.MapPost("/api/invoices/payments/{paymentId}/reject", async (
    string paymentId,
    IInvoiceRepository repository,
    CancellationToken token) =>
{
    var success = await repository.RejectPaymentAsync(paymentId, token);
    return success
        ? Results.Ok(new { message = "Đã từ chối chứng từ thanh toán." })
        : Results.NotFound(new { message = "Không tìm thấy giao dịch này." });
});

app.MapPost("/api/invoices/penalties/{penaltyId}/waive", async (
    string penaltyId,
    IInvoiceRepository repository,
    CancellationToken token) =>
{
    var success = await repository.WaivePenaltyAsync(penaltyId, token);
    return success
        ? Results.Ok(new { message = "Đã duyệt miễn giảm lãi phạt quá hạn thành công!" })
        : Results.NotFound(new { message = "Không tìm thấy bản ghi phạt." });
});

app.MapPost("/api/invoices/reminders/send-batch", async (
    IInvoiceRepository repository,
    CancellationToken token) =>
{
    var count = await repository.SendBatchRemindersAsync(token);
    return Results.Ok(new { count, message = $"Đã gửi thông báo nhắc nợ đồng loạt đến {count} căn hộ qua SMS & App!" });
});

app.MapPost("/api/invoices/generate-monthly", async (
    GenerateMonthlyInvoiceRequest request,
    IInvoiceRepository repository,
    CancellationToken token) =>
{
    var count = await repository.GenerateMonthlyInvoicesAsync(request.Month, request.Year, token);
    return Results.Ok(new { count, message = $"Đã tính và phát hành thành công {count} hóa đơn cho kỳ T{request.Month:00}/{request.Year}!" });
});


// 4. CẤU HÌNH BIỂU PHÍ (SERVICE TARIFFS CONFIGURATION)

app.MapGet("/api/tariffs", async (
    ITariffRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetTariffConfigAsync(token)));

app.MapPut("/api/tariffs/price", async (
    UpdateTariffPriceRequest request,
    ITariffRepository repository,
    CancellationToken token) =>
{
    var success = await repository.UpdateTariffPriceAsync(request, token);
    return success
        ? Results.Ok(new { message = "Đã cập nhật đơn giá dịch vụ thành công!" })
        : Results.NotFound(new { message = "Không tìm thấy biểu phí cần sửa." });
});

app.MapPut("/api/tariffs/rules", async (
    UpdateRulesRequest request,
    ITariffRepository repository,
    CancellationToken token) =>
{
    var success = await repository.UpdateRulesAsync(request, token);
    return Results.Ok(new { success, message = "Đã lưu quy tắc ân hạn và chế tài vận hành thành công!" });
});

app.MapPost("/api/tariffs/approve-draft", async (
    ITariffRepository repository,
    CancellationToken token) =>
{
    var success = await repository.ApproveDraftTariffAsync(token);
    return Results.Ok(new { success, message = "Đã phê duyệt & ký số điện tử ban hành biểu phí mới!" });
});


// 5. KỸ THUẬT VẬN HÀNH MEP & CHỈ SỐ ĐIỆN NƯỚC (LONG - TRANG 3)

app.MapGet("/api/utility-meters", async (
    string? buildingId,
    string? meterType,
    string? search,
    IUtilityRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetMeterListAsync(buildingId, meterType, search, token)));

app.MapGet("/api/utility-usages", async (
    string? buildingId,
    int? floorNumber,
    string? meterType,
    int? month,
    int? year,
    string? search,
    IUtilityRepository repository,
    CancellationToken token) =>
{
    var m = month ?? DateTime.Now.Month;
    var y = year ?? DateTime.Now.Year;
    return Results.Ok(await repository.GetUsageListAsync(buildingId, floorNumber, meterType, m, y, search, token));
});

app.MapGet("/api/utility/summary", async (
    string? buildingId,
    int? month,
    int? year,
    IUtilityRepository repository,
    CancellationToken token) =>
{
    var m = month ?? DateTime.Now.Month;
    var y = year ?? DateTime.Now.Year;
    return Results.Ok(await repository.GetSummaryMetricsAsync(buildingId, m, y, token));
});

app.MapPost("/api/utility/record", async (
    RecordMeterReadingRequest request,
    IUtilityRepository repository,
    CancellationToken token) =>
{
    if (string.IsNullOrWhiteSpace(request.MeterId))
        return Results.BadRequest(new { message = "Vui lòng chọn đồng hồ đo" });

    try
    {
        var usageId = await repository.RecordReadingAsync(request, token);
        return Results.Ok(new { usageId, message = "Ghi nhận chỉ số thành công!" });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { message = ex.Message });
    }
});

app.MapPost("/api/utility/meters", async (
    CreateMeterRequest request,
    IUtilityRepository repository,
    CancellationToken token) =>
{
    if (string.IsNullOrWhiteSpace(request.ApartmentId))
        return Results.BadRequest(new { message = "Vui lòng chọn căn hộ" });
    if (string.IsNullOrWhiteSpace(request.MeterSerialNumber))
        return Results.BadRequest(new { message = "Số seri đồng hồ không được để trống" });

    try
    {
        var meterId = await repository.RegisterMeterAsync(request, token);
        return Results.Created($"/api/utility-meters/{meterId}", new { meterId, message = "Đăng ký lắp đặt công tơ mới thành công!" });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { message = ex.Message });
    }
});

app.MapPost("/api/utility/lock-cycle", async (
    string buildingId,
    int month,
    int year,
    IUtilityRepository repository,
    CancellationToken token) =>
{
    var success = await repository.LockBillingCycleAsync(buildingId, month, year, token);
    return Results.Ok(new { success, message = success ? "Đã chốt sổ chỉ số MEP toàn tòa nhà thành công!" : "Chưa hoàn tất: Vẫn còn căn hộ chưa ghi đủ số điện/nước." });
});


// 6. PHẢN ÁNH SỰ CỐ & NGHIỆM THU HIỆN TRƯỜNG (LONG - TRANG 9)

app.MapGet("/api/complaints", async (
    string? buildingId,
    string? category,
    string? status,
    string? search,
    IComplaintRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetListAsync(buildingId, category, status, search, token)));

app.MapGet("/api/complaints/summary", async (
    string? buildingId,
    IComplaintRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetMetricsAsync(buildingId, token)));

app.MapGet("/api/complaints/{id}", async (
    string id,
    IComplaintRepository repository,
    CancellationToken token) =>
{
    var item = await repository.GetDetailAsync(id, token);
    return item is null ? Results.NotFound(new { message = "Không tìm thấy phiếu khiếu nại" }) : Results.Ok(item);
});

app.MapPost("/api/complaints", async (
    CreateComplaintRequest request,
    IComplaintRepository repository,
    CancellationToken token) =>
{
    if (string.IsNullOrWhiteSpace(request.Title) || string.IsNullOrWhiteSpace(request.Content))
        return Results.BadRequest(new { message = "Tiêu đề và nội dung phản ánh không được để trống" });

    try
    {
        var id = await repository.CreateComplaintAsync(request, token);
        return Results.Created($"/api/complaints/{id}", new { id, message = "Tiếp nhận phiếu phản ánh sự cố thành công!" });
    }
    catch (Exception ex)
    {
        return Results.Problem(detail: ex.Message, statusCode: 500, title: "Lỗi tạo phản ánh");
    }
});

app.MapPut("/api/complaints/{id}/assign", async (
    string id,
    AssignComplaintRequest request,
    IComplaintRepository repository,
    CancellationToken token) =>
{
    var success = await repository.AssignComplaintAsync(request with { ComplaintId = id }, token);
    return success
        ? Results.Ok(new { message = $"Đã phân công xử lý cho '{request.AssignedToRoleOrName}' thành công!" })
        : Results.NotFound(new { message = "Không tìm thấy phiếu cần phân công" });
});

app.MapPut("/api/complaints/{id}/resolve", async (
    string id,
    ResolveComplaintRequest request,
    IComplaintRepository repository,
    CancellationToken token) =>
{
    if (string.IsNullOrWhiteSpace(request.ResolvedImageUrl))
        return Results.BadRequest(new { message = "Bắt buộc phải tải ảnh nghiệm thu thực tế trước khi hoàn thành" });

    var success = await repository.ResolveComplaintAsync(request with { ComplaintId = id }, token);
    return success
        ? Results.Ok(new { message = "Nghiệm thu sự cố thành công! Đã lưu ảnh minh chứng sau sửa chữa." })
        : Results.NotFound(new { message = "Không tìm thấy phiếu cần nghiệm thu" });
});

app.MapPut("/api/complaints/{id}/status", async (
    string id,
    UpdateComplaintStatusRequest request,
    IComplaintRepository repository,
    CancellationToken token) =>
{
    var success = await repository.UpdateStatusAsync(id, request.Status, token);
    return success
        ? Results.Ok(new { message = $"Đã cập nhật trạng thái sự cố sang '{request.Status}' thành công!" })
        : Results.NotFound(new { message = "Không tìm thấy phiếu khiếu nại" });
});


// SYSTEM

app.MapGet("/api/health", () => Results.Ok(new { status = "ok" }));

app.Run();
