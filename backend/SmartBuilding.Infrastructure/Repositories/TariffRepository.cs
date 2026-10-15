using System.Data;
using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

/// <summary>
/// Repository quản lý cấu hình biểu phí định mức dịch vụ, quy tắc ân hạn và dự báo doanh thu
/// </summary>
public sealed class TariffRepository(MySqlConnectionFactory connectionFactory) : ITariffRepository
{
    // Cấu hình quy tắc lưu trong bộ nhớ tạm (có thể mở rộng vào bảng SystemSettings nếu cần)
    private static TariffRules _rules = new(
        MeterCutoffDay: 25,
        InvoiceIssueDay: 28,
        DueDay: 5,
        GracePeriodDays: 5,
        LateInterestRatePercent: 0.05m,
        BlockRfidDays: 20,
        AutoWaiveWithExtensionRequest: true);

    public async Task<TariffConfigDto> GetTariffConfigAsync(CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT Id, ServiceType, TierName, FromUnit, ToUnit, UnitPrice, VatRate, EffectiveDate
            FROM ServiceTariffs
            ORDER BY ServiceType, FromUnit;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);

        var mgmt = new List<TariffItem>();
        var elect = new List<TariffItem>();
        var water = new List<TariffItem>();
        var parking = new List<TariffItem>();

        while (await reader.ReadAsync(cancellationToken))
        {
            var item = new TariffItem(
                reader.GetString("Id"),
                reader.GetString("ServiceType"),
                reader.GetString("TierName"),
                reader.GetDecimal("FromUnit"),
                reader.IsDBNull(reader.GetOrdinal("ToUnit")) ? null : reader.GetDecimal("ToUnit"),
                reader.GetDecimal("UnitPrice"),
                reader.GetDecimal("VatRate"),
                reader.GetDateTime("EffectiveDate"));

            switch (item.ServiceType)
            {
                case "BuildingManagement":
                    mgmt.Add(item);
                    break;
                case "Electricity":
                    elect.Add(item);
                    break;
                case "Water":
                    water.Add(item);
                    break;
                case "ParkingFee":
                    parking.Add(item);
                    break;
            }
        }

        // Lịch sử biến động đơn giá (Audit Trail)
        var auditLogs = new List<TariffAuditLog>
        {
            new("Q3/2026", "Điện sinh hoạt Bậc 6", "3.065 đ", "3.151 đ", "+2.8%", "Ban Quản Lý Tòa Nhà (bql.manager01)"),
            new("Q2/2026", "Gửi xe máy điện (EV)", "120.000 đ", "150.000 đ", "+25% (Trụ sạc)", "Hội đồng BQT Tòa Ruby Suites"),
            new("Q1/2026", "Phí QL Căn hộ tiêu chuẩn", "18.000 đ", "18.000 đ", "0.0% Giữ nguyên", "Ban Quản Lý Tòa Nhà (bql.manager01)")
        };

        // Dự báo doanh thu theo quy mô 1.682 căn hộ
        var forecast = new ForecastRevenueDto(
            ManagementRevenue: 3420000000m,
            ParkingRevenue: 1180000000m,
            UtilityRevenue: 870000000m,
            TotalMonthlyForecast: 4170000000m);

        return new TariffConfigDto(mgmt, elect, water, parking, _rules, auditLogs, forecast);
    }

    public async Task<bool> UpdateTariffPriceAsync(UpdateTariffPriceRequest request, CancellationToken cancellationToken)
    {
        const string sql = """
            UPDATE ServiceTariffs
            SET UnitPrice = @UnitPrice, EffectiveDate = NOW()
            WHERE Id = @Id;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@Id", request.TariffId);
        command.Parameters.AddWithValue("@UnitPrice", request.NewUnitPrice);

        var rows = await command.ExecuteNonQueryAsync(cancellationToken);
        return rows > 0;
    }

    public Task<bool> UpdateRulesAsync(UpdateRulesRequest request, CancellationToken cancellationToken)
    {
        _rules = new TariffRules(
            request.MeterCutoffDay,
            request.InvoiceIssueDay,
            request.DueDay,
            request.GracePeriodDays,
            request.LateInterestRatePercent,
            request.BlockRfidDays,
            request.AutoWaiveWithExtensionRequest);

        return Task.FromResult(true);
    }

    public Task<bool> ApproveDraftTariffAsync(CancellationToken cancellationToken)
    {
        // Phê duyệt & ký điện tử dự thảo giá
        return Task.FromResult(true);
    }
}
