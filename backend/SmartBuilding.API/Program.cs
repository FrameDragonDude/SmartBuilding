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


// 5. MÀN HÌNH TRANG CHỦ (HOME SCREEN)

app.MapGet("/api/home", async (
    string? residentId,
    IHomeRepository repository,
    CancellationToken token) =>
    Results.Ok(await repository.GetHomeDataAsync(residentId, token)));


// 6. XÁC THỰC & TÀI KHOẢN (AUTH & ACCOUNTS)

app.MapPost("/api/auth/login", async (
    LoginRequest request,
    IAuthRepository repository,
    CancellationToken token) =>
{
    if (string.IsNullOrWhiteSpace(request.UsernameOrEmail) || string.IsNullOrWhiteSpace(request.Password))
    {
        return Results.BadRequest(new { message = "Vui lòng nhập tên đăng nhập/email và mật khẩu!" });
    }

    var result = await repository.LoginAsync(request, token);
    return result is not null
        ? Results.Ok(result)
        : Results.BadRequest(new { message = "Tên đăng nhập hoặc mật khẩu không chính xác!" });
});

app.MapPost("/api/auth/register", async (
    RegisterRequest request,
    IAuthRepository repository,
    CancellationToken token) =>
{
    if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password) || string.IsNullOrWhiteSpace(request.FullName))
    {
        return Results.BadRequest(new { message = "Vui lòng điền đầy đủ thông tin bắt buộc!" });
    }

    try
    {
        var result = await repository.RegisterAsync(request, token);
        return Results.Ok(result);
    }
    catch (Exception ex)
    {
        return Results.Problem(detail: ex.Message, statusCode: 400, title: "Lỗi đăng ký");
    }
});


// SYSTEM

app.MapGet("/api/health", () => Results.Ok(new { status = "ok" }));

app.Run();
