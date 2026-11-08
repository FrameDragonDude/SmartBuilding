using System.Data;
using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

public sealed class UtilityRepository(MySqlConnectionFactory connectionFactory) : IUtilityRepository
{
    public async Task<IReadOnlyList<UtilityMeterDto>> GetMeterListAsync(
        string? buildingId,
        string? meterType,
        string? search,
        CancellationToken cancellationToken)
    {
        var sql = """
            SELECT m.Id, m.ApartmentId, a.ApartmentNumber, b.Id AS BuildingId, b.Name AS BuildingName,
                   f.FloorNumber, m.MeterType, m.MeterSerialNumber, m.InstallationDate, m.IsActive
            FROM UtilityMeters m
            INNER JOIN Apartments a ON a.Id = m.ApartmentId
            INNER JOIN Floors f ON f.Id = a.FloorId
            INNER JOIN Buildings b ON b.Id = f.BuildingId
            WHERE 1=1
            """;

        if (!string.IsNullOrWhiteSpace(buildingId))
            sql += " AND b.Id = @BuildingId";
        if (!string.IsNullOrWhiteSpace(meterType) && meterType != "All")
            sql += " AND m.MeterType = @MeterType";
        if (!string.IsNullOrWhiteSpace(search))
            sql += " AND (a.ApartmentNumber LIKE @Search OR m.MeterSerialNumber LIKE @Search)";

        sql += " ORDER BY b.BuildingCode, f.FloorNumber, a.ApartmentNumber, m.MeterType;";

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        if (!string.IsNullOrWhiteSpace(buildingId))
            command.Parameters.AddWithValue("@BuildingId", buildingId);
        if (!string.IsNullOrWhiteSpace(meterType) && meterType != "All")
            command.Parameters.AddWithValue("@MeterType", meterType);
        if (!string.IsNullOrWhiteSpace(search))
            command.Parameters.AddWithValue("@Search", $"%{search}%");

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var list = new List<UtilityMeterDto>();

        while (await reader.ReadAsync(cancellationToken))
        {
            list.Add(new UtilityMeterDto(
                reader.GetString("Id"),
                reader.GetString("ApartmentId"),
                reader.GetString("ApartmentNumber"),
                reader.GetString("BuildingId"),
                reader.GetString("BuildingName"),
                reader.GetInt32("FloorNumber"),
                reader.GetString("MeterType"),
                reader.GetString("MeterSerialNumber"),
                reader.GetDateTime("InstallationDate"),
                reader.GetBoolean("IsActive")));
        }

        return list;
    }

    public async Task<IReadOnlyList<UtilityUsageListItem>> GetUsageListAsync(
        string? buildingId,
        int? floorNumber,
        string? meterType,
        int month,
        int year,
        string? search,
        CancellationToken cancellationToken)
    {
        var sql = """
            SELECT 
                COALESCE(u.Id, '') AS UsageId,
                m.Id AS MeterId,
                a.Id AS ApartmentId,
                a.ApartmentNumber,
                b.Id AS BuildingId,
                b.Name AS BuildingName,
                f.FloorNumber,
                m.MeterType,
                m.MeterSerialNumber,
                COALESCE(u.BillingMonth, @Month) AS BillingMonth,
                COALESCE(u.BillingYear, @Year) AS BillingYear,
                COALESCE(u.PreviousReading, 
                    (SELECT COALESCE(prev.CurrentReading, 0)
                     FROM UtilityUsages prev 
                     WHERE prev.MeterId = m.Id 
                       AND (prev.BillingYear < @Year OR (prev.BillingYear = @Year AND prev.BillingMonth < @Month))
                     ORDER BY prev.BillingYear DESC, prev.BillingMonth DESC 
                     LIMIT 1), 0) AS PreviousReading,
                COALESCE(u.CurrentReading, 0) AS CurrentReading,
                COALESCE(u.Consumption, 0) AS Consumption,
                COALESCE(u.CalculatedAmount, 0) AS CalculatedAmount,
                u.ProofImageUrl,
                u.RecordedAt,
                (CASE WHEN u.Id IS NOT NULL THEN 1 ELSE 0 END) AS IsRecorded
            FROM UtilityMeters m
            INNER JOIN Apartments a ON a.Id = m.ApartmentId
            INNER JOIN Floors f ON f.Id = a.FloorId
            INNER JOIN Buildings b ON b.Id = f.BuildingId
            LEFT JOIN UtilityUsages u ON u.MeterId = m.Id AND u.BillingMonth = @Month AND u.BillingYear = @Year
            WHERE m.IsActive = 1
            """;

        if (!string.IsNullOrWhiteSpace(buildingId))
            sql += " AND b.Id = @BuildingId";
        if (floorNumber.HasValue)
            sql += " AND f.FloorNumber = @FloorNumber";
        if (!string.IsNullOrWhiteSpace(meterType) && meterType != "All")
            sql += " AND m.MeterType = @MeterType";
        if (!string.IsNullOrWhiteSpace(search))
            sql += " AND (a.ApartmentNumber LIKE @Search OR m.MeterSerialNumber LIKE @Search)";

        sql += " ORDER BY b.BuildingCode, f.FloorNumber, a.ApartmentNumber, m.MeterType;";

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        command.Parameters.AddWithValue("@Month", month);
        command.Parameters.AddWithValue("@Year", year);

        if (!string.IsNullOrWhiteSpace(buildingId))
            command.Parameters.AddWithValue("@BuildingId", buildingId);
        if (floorNumber.HasValue)
            command.Parameters.AddWithValue("@FloorNumber", floorNumber.Value);
        if (!string.IsNullOrWhiteSpace(meterType) && meterType != "All")
            command.Parameters.AddWithValue("@MeterType", meterType);
        if (!string.IsNullOrWhiteSpace(search))
            command.Parameters.AddWithValue("@Search", $"%{search}%");

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var list = new List<UtilityUsageListItem>();

        while (await reader.ReadAsync(cancellationToken))
        {
            var isRecorded = reader.GetInt32("IsRecorded") == 1;
            var prevReading = reader.GetDecimal("PreviousReading");
            var currReading = reader.GetDecimal("CurrentReading");
            var consumption = reader.GetDecimal("Consumption");
            var mType = reader.GetString("MeterType");

            var hasAnomaly = false;
            string? anomalyReason = null;

            if (isRecorded)
            {
                if (currReading < prevReading)
                {
                    hasAnomaly = true;
                    anomalyReason = "Số mới nhỏ hơn số cũ (ngược số)";
                }
                else if (mType == "Electricity" && consumption > 600)
                {
                    hasAnomaly = true;
                    anomalyReason = "Sản lượng điện vượt ngưỡng 600 kWh/tháng";
                }
                else if (mType == "Water" && consumption > 50)
                {
                    hasAnomaly = true;
                    anomalyReason = "Sản lượng nước vượt ngưỡng 50 m3/tháng";
                }
            }

            list.Add(new UtilityUsageListItem(
                reader.GetString("UsageId"),
                reader.GetString("MeterId"),
                reader.GetString("ApartmentId"),
                reader.GetString("ApartmentNumber"),
                reader.GetString("BuildingId"),
                reader.GetString("BuildingName"),
                reader.GetInt32("FloorNumber"),
                mType,
                reader.GetString("MeterSerialNumber"),
                reader.GetInt32("BillingMonth"),
                reader.GetInt32("BillingYear"),
                prevReading,
                currReading,
                consumption,
                reader.GetDecimal("CalculatedAmount"),
                reader.IsDBNull(reader.GetOrdinal("ProofImageUrl")) ? null : reader.GetString("ProofImageUrl"),
                reader.IsDBNull(reader.GetOrdinal("RecordedAt")) ? null : reader.GetDateTime("RecordedAt"),
                isRecorded,
                hasAnomaly,
                anomalyReason));
        }

        return list;
    }

    public async Task<UtilitySummaryMetrics> GetSummaryMetricsAsync(
        string? buildingId,
        int month,
        int year,
        CancellationToken cancellationToken)
    {
        var sql = """
            SELECT 
                COUNT(m.Id) AS TotalMeters,
                SUM(CASE WHEN m.MeterType = 'Electricity' THEN 1 ELSE 0 END) AS ElectricityMetersCount,
                SUM(CASE WHEN m.MeterType = 'Water' THEN 1 ELSE 0 END) AS WaterMetersCount,
                SUM(CASE WHEN u.Id IS NOT NULL THEN 1 ELSE 0 END) AS RecordedCount,
                SUM(CASE WHEN u.Id IS NULL THEN 1 ELSE 0 END) AS PendingCount,
                COALESCE(SUM(CASE WHEN m.MeterType = 'Electricity' THEN u.Consumption ELSE 0 END), 0) AS TotalElectricityKwh,
                COALESCE(SUM(CASE WHEN m.MeterType = 'Water' THEN u.Consumption ELSE 0 END), 0) AS TotalWaterM3,
                COALESCE(SUM(CASE WHEN u.CurrentReading < u.PreviousReading OR (m.MeterType = 'Electricity' AND u.Consumption > 600) OR (m.MeterType = 'Water' AND u.Consumption > 50) THEN 1 ELSE 0 END), 0) AS AnomalyAlertsCount
            FROM UtilityMeters m
            INNER JOIN Apartments a ON a.Id = m.ApartmentId
            INNER JOIN Floors f ON f.Id = a.FloorId
            INNER JOIN Buildings b ON b.Id = f.BuildingId
            LEFT JOIN UtilityUsages u ON u.MeterId = m.Id AND u.BillingMonth = @Month AND u.BillingYear = @Year
            WHERE m.IsActive = 1
            """;

        if (!string.IsNullOrWhiteSpace(buildingId))
            sql += " AND b.Id = @BuildingId";

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@Month", month);
        command.Parameters.AddWithValue("@Year", year);

        if (!string.IsNullOrWhiteSpace(buildingId))
            command.Parameters.AddWithValue("@BuildingId", buildingId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new UtilitySummaryMetrics(
                Convert.ToInt32(reader.GetInt64("TotalMeters")),
                Convert.ToInt32(reader.GetDecimal("ElectricityMetersCount")),
                Convert.ToInt32(reader.GetDecimal("WaterMetersCount")),
                Convert.ToInt32(reader.GetDecimal("RecordedCount")),
                Convert.ToInt32(reader.GetDecimal("PendingCount")),
                reader.GetDecimal("TotalElectricityKwh"),
                reader.GetDecimal("TotalWaterM3"),
                Convert.ToInt32(reader.GetDecimal("AnomalyAlertsCount")));
        }

        return new UtilitySummaryMetrics(0, 0, 0, 0, 0, 0, 0, 0);
    }

    public async Task<string> RecordReadingAsync(
        RecordMeterReadingRequest request,
        CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        // 1. Lấy thông tin đồng hồ và chỉ số kỳ trước
        const string queryMeter = """
            SELECT m.Id, m.MeterType,
                COALESCE(
                    (SELECT prev.CurrentReading
                     FROM UtilityUsages prev
                     WHERE prev.MeterId = m.Id
                       AND (prev.BillingYear < @Year OR (prev.BillingYear = @Year AND prev.BillingMonth < @Month))
                     ORDER BY prev.BillingYear DESC, prev.BillingMonth DESC
                     LIMIT 1), 0) AS PreviousReading
            FROM UtilityMeters m
            WHERE m.Id = @MeterId;
            """;

        await using var cmdMeter = new MySqlCommand(queryMeter, connection);
        cmdMeter.Parameters.AddWithValue("@MeterId", request.MeterId);
        cmdMeter.Parameters.AddWithValue("@Month", request.BillingMonth);
        cmdMeter.Parameters.AddWithValue("@Year", request.BillingYear);

        string meterType = "Electricity";
        decimal previousReading = 0;

        await using (var reader = await cmdMeter.ExecuteReaderAsync(cancellationToken))
        {
            if (await reader.ReadAsync(cancellationToken))
            {
                meterType = reader.GetString("MeterType");
                previousReading = reader.GetDecimal("PreviousReading");
            }
            else
            {
                throw new KeyNotFoundException($"Không tìm thấy đồng hồ {request.MeterId}");
            }
        }

        if (request.CurrentReading < previousReading)
        {
            throw new InvalidOperationException($"Chỉ số mới ({request.CurrentReading}) không được nhỏ hơn chỉ số kỳ trước ({previousReading}).");
        }

        var consumption = request.CurrentReading - previousReading;
        decimal calculatedAmount = meterType == "Electricity"
            ? CalculateElectricityCost(consumption)
            : CalculateWaterCost(consumption);

        // 2. Chèn hoặc cập nhật (Upsert)
        const string upsertSql = """
            INSERT INTO UtilityUsages (Id, MeterId, BillingMonth, BillingYear, PreviousReading, CurrentReading, CalculatedAmount, ProofImageUrl, RecordedAt)
            VALUES (@Id, @MeterId, @Month, @Year, @PreviousReading, @CurrentReading, @CalculatedAmount, @ProofImageUrl, NOW(6))
            ON DUPLICATE KEY UPDATE
                PreviousReading = VALUES(PreviousReading),
                CurrentReading = VALUES(CurrentReading),
                CalculatedAmount = VALUES(CalculatedAmount),
                ProofImageUrl = COALESCE(VALUES(ProofImageUrl), ProofImageUrl),
                RecordedAt = NOW(6);
            """;

        var usageId = Guid.NewGuid().ToString();
        await using var cmdUpsert = new MySqlCommand(upsertSql, connection);
        cmdUpsert.Parameters.AddWithValue("@Id", usageId);
        cmdUpsert.Parameters.AddWithValue("@MeterId", request.MeterId);
        cmdUpsert.Parameters.AddWithValue("@Month", request.BillingMonth);
        cmdUpsert.Parameters.AddWithValue("@Year", request.BillingYear);
        cmdUpsert.Parameters.AddWithValue("@PreviousReading", previousReading);
        cmdUpsert.Parameters.AddWithValue("@CurrentReading", request.CurrentReading);
        cmdUpsert.Parameters.AddWithValue("@CalculatedAmount", calculatedAmount);
        cmdUpsert.Parameters.AddWithValue("@ProofImageUrl", (object?)request.ProofImageUrl ?? DBNull.Value);

        await cmdUpsert.ExecuteNonQueryAsync(cancellationToken);
        return usageId;
    }

    public async Task<string> RegisterMeterAsync(
        CreateMeterRequest request,
        CancellationToken cancellationToken)
    {
        const string sql = """
            INSERT INTO UtilityMeters (Id, ApartmentId, MeterType, MeterSerialNumber, InstallationDate, IsActive)
            VALUES (@Id, @ApartmentId, @MeterType, @MeterSerialNumber, @InstallationDate, 1);
            """;

        var id = Guid.NewGuid().ToString();
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        command.Parameters.AddWithValue("@Id", id);
        command.Parameters.AddWithValue("@ApartmentId", request.ApartmentId);
        command.Parameters.AddWithValue("@MeterType", request.MeterType);
        command.Parameters.AddWithValue("@MeterSerialNumber", request.MeterSerialNumber);
        command.Parameters.AddWithValue("@InstallationDate", request.InstallationDate ?? DateTime.UtcNow);

        await command.ExecuteNonQueryAsync(cancellationToken);
        return id;
    }

    public async Task<bool> LockBillingCycleAsync(
        string buildingId,
        int month,
        int year,
        CancellationToken cancellationToken)
    {
        // Khi chốt sổ, cập nhật hoặc ghi nhận trạng thái hoàn thành chu kỳ ghi số
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        
        // Kiểm tra xem đã ghi nhận đầy đủ chưa
        const string checkSql = """
            SELECT COUNT(*)
            FROM UtilityMeters m
            INNER JOIN Apartments a ON a.Id = m.ApartmentId
            INNER JOIN Floors f ON f.Id = a.FloorId
            LEFT JOIN UtilityUsages u ON u.MeterId = m.Id AND u.BillingMonth = @Month AND u.BillingYear = @Year
            WHERE f.BuildingId = @BuildingId AND m.IsActive = 1 AND u.Id IS NULL;
            """;

        await using var cmdCheck = new MySqlCommand(checkSql, connection);
        cmdCheck.Parameters.AddWithValue("@BuildingId", buildingId);
        cmdCheck.Parameters.AddWithValue("@Month", month);
        cmdCheck.Parameters.AddWithValue("@Year", year);

        var unrecorded = Convert.ToInt32(await cmdCheck.ExecuteScalarAsync(cancellationToken));
        return unrecorded == 0;
    }

    // Biểu giá Điện sinh hoạt 6 bậc EVN chuẩn
    private static decimal CalculateElectricityCost(decimal kwh)
    {
        if (kwh <= 0) return 0;
        decimal total = 0;
        decimal remaining = kwh;

        // Bậc 1: 0 - 50 kWh: 1,893 đ/kWh
        var b1 = Math.Min(remaining, 50);
        total += b1 * 1893m;
        remaining -= b1;
        if (remaining <= 0) return Math.Round(total, 2);

        // Bậc 2: 51 - 100 kWh: 1,956 đ/kWh
        var b2 = Math.Min(remaining, 50);
        total += b2 * 1956m;
        remaining -= b2;
        if (remaining <= 0) return Math.Round(total, 2);

        // Bậc 3: 101 - 200 kWh: 2,271 đ/kWh
        var b3 = Math.Min(remaining, 100);
        total += b3 * 2271m;
        remaining -= b3;
        if (remaining <= 0) return Math.Round(total, 2);

        // Bậc 4: 201 - 300 kWh: 2,860 đ/kWh
        var b4 = Math.Min(remaining, 100);
        total += b4 * 2860m;
        remaining -= b4;
        if (remaining <= 0) return Math.Round(total, 2);

        // Bậc 5: 301 - 400 kWh: 3,197 đ/kWh
        var b5 = Math.Min(remaining, 100);
        total += b5 * 3197m;
        remaining -= b5;
        if (remaining <= 0) return Math.Round(total, 2);

        // Bậc 6: > 400 kWh: 3,302 đ/kWh
        total += remaining * 3302m;
        return Math.Round(total, 2);
    }

    // Biểu giá Nước sinh hoạt + Phí BVMT
    private static decimal CalculateWaterCost(decimal m3)
    {
        if (m3 <= 0) return 0;
        // Đơn giá trung bình 15,500 đ/m3 đã bao gồm phí BVMT 10%
        return Math.Round(m3 * 15500m, 2);
    }
}
