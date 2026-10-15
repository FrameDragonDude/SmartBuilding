using System.Data;
using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

public sealed class ParkingRepository(MySqlConnectionFactory connectionFactory) : IParkingRepository
{
    public async Task<IReadOnlyList<ParkingListItem>> GetListAsync(
        string? search,
        string? basement,
        string? slotType,
        bool? isOccupied,
        string? buildingId,
        CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT ps.Id SlotId, ps.SlotCode, ps.BasementLevel, ps.SlotType, ps.IsOccupied,
                   v.Id VehicleId, v.VehicleType, v.LicensePlate, v.RfidCardCode, v.Brand,
                   r.FullName, r.PhoneNumber, a.ApartmentNumber
            FROM ParkingSlots ps
            LEFT JOIN Vehicles v ON v.Id = ps.VehicleId
            LEFT JOIN Residents r ON r.Id = v.ResidentId
            LEFT JOIN Apartments a ON a.Id = v.ApartmentId
            WHERE (@search IS NULL OR @search = '' OR ps.SlotCode LIKE CONCAT('%', @search, '%')
                OR v.LicensePlate LIKE CONCAT('%', @search, '%') OR v.RfidCardCode LIKE CONCAT('%', @search, '%')
                OR r.FullName LIKE CONCAT('%', @search, '%') OR a.ApartmentNumber LIKE CONCAT('%', @search, '%'))
              AND (@basement IS NULL OR @basement = '' OR @basement = 'All' OR ps.BasementLevel = @basement)
              AND (@slotType IS NULL OR @slotType = '' OR @slotType = 'All' OR ps.SlotType = @slotType)
              AND (@isOccupied IS NULL OR ps.IsOccupied = @isOccupied)
              AND (@buildingId IS NULL OR @buildingId = '' OR @buildingId = 'All' OR ps.BuildingId = @buildingId)
            ORDER BY ps.BasementLevel ASC, ps.SlotCode ASC LIMIT 200;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@search", string.IsNullOrWhiteSpace(search) ? DBNull.Value : search.Trim());
        command.Parameters.AddWithValue("@basement", string.IsNullOrWhiteSpace(basement) ? DBNull.Value : basement.Trim());
        command.Parameters.AddWithValue("@slotType", string.IsNullOrWhiteSpace(slotType) ? DBNull.Value : slotType.Trim());
        command.Parameters.AddWithValue("@isOccupied", (object?)isOccupied ?? DBNull.Value);
        command.Parameters.AddWithValue("@buildingId", string.IsNullOrWhiteSpace(buildingId) ? DBNull.Value : buildingId.Trim());

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var result = new List<ParkingListItem>();

        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new ParkingListItem(
                reader.GetString("SlotId"),
                reader.GetString("SlotCode"),
                reader.GetString("BasementLevel"),
                reader.GetString("SlotType"),
                reader.GetBoolean("IsOccupied"),
                GetNullableString(reader, "VehicleId"),
                GetNullableString(reader, "VehicleType"),
                GetNullableString(reader, "LicensePlate"),
                GetNullableString(reader, "RfidCardCode"),
                GetNullableString(reader, "Brand"),
                GetNullableString(reader, "FullName"),
                GetNullableString(reader, "PhoneNumber"),
                GetNullableString(reader, "ApartmentNumber")));
        }

        return result;
    }

    public async Task<ParkingSummaryMetrics> GetMetricsAsync(string? buildingId, CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT
                COUNT(*) AS TotalSlots,
                COALESCE(SUM(CASE WHEN IsOccupied = 1 THEN 1 ELSE 0 END), 0) AS OccupiedSlots,
                COALESCE(SUM(CASE WHEN IsOccupied = 0 THEN 1 ELSE 0 END), 0) AS AvailableSlots,
                COALESCE(SUM(CASE WHEN BasementLevel = 'B1' THEN 1 ELSE 0 END), 0) AS B1Total,
                COALESCE(SUM(CASE WHEN BasementLevel = 'B1' AND IsOccupied = 1 THEN 1 ELSE 0 END), 0) AS B1Occupied,
                COALESCE(SUM(CASE WHEN BasementLevel = 'B2' THEN 1 ELSE 0 END), 0) AS B2Total,
                COALESCE(SUM(CASE WHEN BasementLevel = 'B2' AND IsOccupied = 1 THEN 1 ELSE 0 END), 0) AS B2Occupied,
                COALESCE(SUM(CASE WHEN SlotType = 'Car' THEN 1 ELSE 0 END), 0) AS CarSlotsTotal,
                COALESCE(SUM(CASE WHEN SlotType = 'Car' AND IsOccupied = 1 THEN 1 ELSE 0 END), 0) AS CarSlotsOccupied,
                COALESCE(SUM(CASE WHEN SlotType = 'Motorbike' THEN 1 ELSE 0 END), 0) AS MotoSlotsTotal,
                COALESCE(SUM(CASE WHEN SlotType = 'Motorbike' AND IsOccupied = 1 THEN 1 ELSE 0 END), 0) AS MotoSlotsOccupied
            FROM ParkingSlots
            WHERE (@buildingId IS NULL OR @buildingId = '' OR @buildingId = 'All' OR BuildingId = @buildingId);
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@buildingId", string.IsNullOrWhiteSpace(buildingId) ? DBNull.Value : buildingId.Trim());
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);

        if (await reader.ReadAsync(cancellationToken))
        {
            return new ParkingSummaryMetrics(
                Convert.ToInt32(reader["TotalSlots"]),
                Convert.ToInt32(reader["OccupiedSlots"]),
                Convert.ToInt32(reader["AvailableSlots"]),
                Convert.ToInt32(reader["B1Total"]),
                Convert.ToInt32(reader["B1Occupied"]),
                Convert.ToInt32(reader["B2Total"]),
                Convert.ToInt32(reader["B2Occupied"]),
                Convert.ToInt32(reader["CarSlotsTotal"]),
                Convert.ToInt32(reader["CarSlotsOccupied"]),
                Convert.ToInt32(reader["MotoSlotsTotal"]),
                Convert.ToInt32(reader["MotoSlotsOccupied"]));
        }

        return new ParkingSummaryMetrics(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    public async Task<ParkingDetailDto?> GetDetailAsync(string slotId, CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT ps.Id SlotId, ps.SlotCode, ps.BasementLevel, ps.SlotType, ps.IsOccupied,
                   v.Id VehicleId, v.VehicleType, v.LicensePlate, v.RfidCardCode, v.Brand, v.IsActive, v.RegisteredAt,
                   r.Id ResidentId, r.FullName, r.PhoneNumber, r.IdentityCardNumber,
                   a.Id ApartmentId, a.ApartmentNumber, b.Name AS BuildingName
            FROM ParkingSlots ps
            JOIN Buildings b ON b.Id = ps.BuildingId
            LEFT JOIN Vehicles v ON v.Id = ps.VehicleId
            LEFT JOIN Residents r ON r.Id = v.ResidentId
            LEFT JOIN Apartments a ON a.Id = v.ApartmentId
            WHERE ps.Id = @SlotId OR ps.SlotCode = @SlotId
            LIMIT 1;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@SlotId", slotId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return new ParkingDetailDto(
            reader.GetString("SlotId"),
            reader.GetString("SlotCode"),
            reader.GetString("BasementLevel"),
            reader.GetString("SlotType"),
            reader.GetBoolean("IsOccupied"),
            GetNullableString(reader, "VehicleId"),
            GetNullableString(reader, "VehicleType"),
            GetNullableString(reader, "LicensePlate"),
            GetNullableString(reader, "RfidCardCode"),
            GetNullableString(reader, "Brand"),
            reader.IsDBNull(reader.GetOrdinal("IsActive")) ? null : reader.GetBoolean("IsActive"),
            reader.IsDBNull(reader.GetOrdinal("RegisteredAt")) ? null : reader.GetDateTime("RegisteredAt"),
            GetNullableString(reader, "ResidentId"),
            GetNullableString(reader, "FullName"),
            GetNullableString(reader, "PhoneNumber"),
            GetNullableString(reader, "IdentityCardNumber"),
            GetNullableString(reader, "ApartmentId"),
            GetNullableString(reader, "ApartmentNumber"),
            reader.GetString("BuildingName"));
    }

    public async Task<string> RegisterVehicleAsync(CreateVehicleRequest request, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var tx = await connection.BeginTransactionAsync(cancellationToken);

        try
        {
            var vehicleId = "VH-" + Guid.NewGuid().ToString("N")[..8];
            const string insertVehicleSql = """
                INSERT INTO Vehicles (Id, ResidentId, ApartmentId, VehicleType, LicensePlate, RfidCardCode, Brand, IsActive, RegisteredAt)
                VALUES (@Id, @ResidentId, @ApartmentId, @VehicleType, @LicensePlate, @RfidCardCode, @Brand, 1, NOW(6));
                """;
            await using (var cmd = new MySqlCommand(insertVehicleSql, connection, tx))
            {
                cmd.Parameters.AddWithValue("@Id", vehicleId);
                cmd.Parameters.AddWithValue("@ResidentId", request.ResidentId);
                cmd.Parameters.AddWithValue("@ApartmentId", request.ApartmentId);
                cmd.Parameters.AddWithValue("@VehicleType", request.VehicleType);
                cmd.Parameters.AddWithValue("@LicensePlate", request.LicensePlate.Trim());
                cmd.Parameters.AddWithValue("@RfidCardCode", request.RfidCardCode.Trim());
                cmd.Parameters.AddWithValue("@Brand", (object?)request.Brand?.Trim() ?? DBNull.Value);
                await cmd.ExecuteNonQueryAsync(cancellationToken);
            }

            string? targetSlotId = request.SlotId;
            if (string.IsNullOrWhiteSpace(targetSlotId))
            {
                var mappedSlotType = request.VehicleType == "Car" ? "Car" : "Motorbike";
                const string findSlotSql = "SELECT Id FROM ParkingSlots WHERE SlotType = @SlotType AND IsOccupied = 0 LIMIT 1;";
                await using (var findCmd = new MySqlCommand(findSlotSql, connection, tx))
                {
                    findCmd.Parameters.AddWithValue("@SlotType", mappedSlotType);
                    var found = await findCmd.ExecuteScalarAsync(cancellationToken);
                    if (found != null && found != DBNull.Value)
                    {
                        targetSlotId = found.ToString();
                    }
                }
            }

            if (!string.IsNullOrWhiteSpace(targetSlotId))
            {
                const string updateSlotSql = "UPDATE ParkingSlots SET VehicleId = @VehicleId, IsOccupied = 1 WHERE Id = @SlotId;";
                await using (var updateCmd = new MySqlCommand(updateSlotSql, connection, tx))
                {
                    updateCmd.Parameters.AddWithValue("@VehicleId", vehicleId);
                    updateCmd.Parameters.AddWithValue("@SlotId", targetSlotId);
                    await updateCmd.ExecuteNonQueryAsync(cancellationToken);
                }
            }

            await tx.CommitAsync(cancellationToken);
            return vehicleId;
        }
        catch
        {
            await tx.RollbackAsync(cancellationToken);
            throw;
        }
    }

    public async Task<bool> ReleaseSlotAsync(string slotId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        const string releaseSql = """
            UPDATE ParkingSlots
            SET VehicleId = NULL, IsOccupied = 0
            WHERE Id = @SlotId OR SlotCode = @SlotId;
            """;
        await using var cmd = new MySqlCommand(releaseSql, connection);
        cmd.Parameters.AddWithValue("@SlotId", slotId);
        var rows = await cmd.ExecuteNonQueryAsync(cancellationToken);
        return rows > 0;
    }

    private static string? GetNullableString(MySqlDataReader reader, string column) =>
        reader.IsDBNull(reader.GetOrdinal(column)) ? null : reader.GetString(column);
}
