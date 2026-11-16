using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

public class AmenityRepository : IAmenityRepository
{
    private readonly MySqlConnectionFactory _connectionFactory;

    public AmenityRepository(MySqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<AmenityDto>> GetAmenitiesAsync(CancellationToken cancellationToken = default)
    {
        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        var list = new List<AmenityDto>();

        const string sql = """
            SELECT
                Id,
                Name,
                ImageUrl,
                MaxCapacity,
                DATE_FORMAT(OpenTime, '%H:%i') AS OpenTime,
                DATE_FORMAT(CloseTime, '%H:%i') AS CloseTime,
                SlotDurationMinutes,
                IsActive
            FROM Amenities
            ORDER BY IsActive DESC, Name;
            """;

        await using var cmd = new MySqlCommand(sql, connection);
        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            list.Add(new AmenityDto
            {
                Id = reader.GetString("Id"),
                Name = reader.GetString("Name"),
                ImageUrl = GetNullableString(reader, "ImageUrl"),
                MaxCapacity = reader.GetInt32("MaxCapacity"),
                OpenTime = reader.GetString("OpenTime"),
                CloseTime = reader.GetString("CloseTime"),
                SlotDurationMinutes = reader.GetInt32("SlotDurationMinutes"),
                IsActive = reader.GetBoolean("IsActive")
            });
        }

        return list;
    }

    public async Task<IReadOnlyList<AmenityBookingDto>> GetMyBookingsAsync(string residentId, CancellationToken cancellationToken = default)
    {
        residentId = string.IsNullOrWhiteSpace(residentId) ? "Res1" : residentId;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        var list = new List<AmenityBookingDto>();

        const string sql = """
            SELECT
                ab.Id,
                ab.AmenityId,
                am.Name AS AmenityName,
                am.ImageUrl AS AmenityImageUrl,
                DATE_FORMAT(ab.StartTime, '%d/%m/%Y') AS BookingDate,
                DATE_FORMAT(ab.StartTime, '%H:%i') AS StartTime,
                DATE_FORMAT(ab.EndTime, '%H:%i') AS EndTime,
                ab.NumberOfGuests,
                ab.Status,
                DATE_FORMAT(ab.CreatedAt, '%d/%m/%Y %H:%i') AS CreatedAt
            FROM AmenityBookings ab
            JOIN Amenities am ON am.Id = ab.AmenityId
            WHERE ab.ResidentId = @ResidentId
            ORDER BY ab.StartTime DESC;
            """;

        await using var cmd = new MySqlCommand(sql, connection);
        cmd.Parameters.AddWithValue("@ResidentId", residentId);

        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            list.Add(new AmenityBookingDto
            {
                Id = reader.GetString("Id"),
                AmenityId = reader.GetString("AmenityId"),
                AmenityName = reader.GetString("AmenityName"),
                AmenityImageUrl = GetNullableString(reader, "AmenityImageUrl"),
                BookingDate = reader.GetString("BookingDate"),
                StartTime = reader.GetString("StartTime"),
                EndTime = reader.GetString("EndTime"),
                NumberOfGuests = reader.GetInt32("NumberOfGuests"),
                Status = reader.GetString("Status"),
                CreatedAt = reader.GetString("CreatedAt")
            });
        }

        return list;
    }

    public async Task<AmenityBookingDetailDto?> GetBookingDetailAsync(string bookingId, CancellationToken cancellationToken = default)
    {
        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        const string sql = """
            SELECT
                ab.Id AS BookingId,
                ab.AmenityId,
                am.Name AS AmenityName,
                am.ImageUrl AS AmenityImageUrl,
                am.MaxCapacity,
                COALESCE(b.Name, 'Tòa Ruby Suites') AS BuildingName,
                COALESCE(ap.ApartmentNumber, 'RB-0101') AS ApartmentNumber,
                COALESCE(ap.FloorNumber, 38) AS FloorNumber,
                COALESCE(r.FullName, 'Nguyễn Văn An') AS ResidentName,
                COALESCE(r.IdentityCard, '079095001234') AS IdCardNumber,
                DATE_FORMAT(ab.StartTime, '%d/%m/%Y') AS BookingDateRaw,
                DATE_FORMAT(ab.StartTime, '%H:%i') AS StartTime,
                DATE_FORMAT(ab.EndTime, '%H:%i') AS EndTime,
                ab.NumberOfGuests,
                ab.Status
            FROM AmenityBookings ab
            JOIN Amenities am ON am.Id = ab.AmenityId
            LEFT JOIN Residents r ON r.Id = ab.ResidentId
            LEFT JOIN Apartments ap ON ap.Id = ab.ApartmentId
            LEFT JOIN Buildings b ON b.Id = ap.BuildingId
            WHERE ab.Id = @BookingId
            LIMIT 1;
            """;

        await using var cmd = new MySqlCommand(sql, connection);
        cmd.Parameters.AddWithValue("@BookingId", bookingId);

        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            var bId = GetStringSafe(reader, "BookingId");
            var buildingName = GetStringSafe(reader, "BuildingName", "Tòa Ruby Suites");
            var apartmentNum = GetStringSafe(reader, "ApartmentNumber", "RB-0101");
            var floorNum = GetIntSafe(reader, "FloorNumber", 38);
            var dateRaw = GetStringSafe(reader, "BookingDateRaw", "12/09/2026");
            var status = GetStringSafe(reader, "Status", "Confirmed");

            var amenityId = GetStringSafe(reader, "AmenityId");
            var amenityName = GetStringSafe(reader, "AmenityName", "Tiện ích chung");
            var locationText = amenityId switch {
                "Amn1" => $"Bếp nướng BBQ-03 • Tầng 38 Tháp {buildingName}",
                "Amn2" => $"Sân Tennis ngoài trời • Khu thể thao {buildingName}",
                "Amn3" => $"Hồ bơi vô cực • Tầng mái Tháp {buildingName}",
                "Amn4" => $"Phòng Gym & Cardio • Tầng 2 {buildingName}",
                "Amn5" => $"Phòng sinh hoạt cộng đồng • Tầng 1 {buildingName}",
                "Amn6" => $"Phòng Yoga & Thiền • Tầng 3 {buildingName}",
                "Amn7" => $"Sân bóng rổ mini • Khu thể thao {buildingName}",
                "Amn8" => $"Khu vui chơi trẻ em • Tầng 1 {buildingName}",
                _ => $"{amenityName} • {buildingName}"
            };

            var cleanApt = apartmentNum.Replace("-", "");
            var cleanDate = dateRaw.Replace("/", "");

            return new AmenityBookingDetailDto
            {
                Id = bId,
                BookingCode = $"#{bId}",
                AmenityId = amenityId,
                BlockName = $"KHỐI {buildingName.ToUpper()}",
                AmenityTitle = amenityName,
                LocationText = locationText,
                TimeRange = $"{GetStringSafe(reader, "StartTime", "18:00")} - {GetStringSafe(reader, "EndTime", "20:00")}",
                BookingDate = $"Hôm nay, {dateRaw}",
                ApartmentNumber = $"Căn {apartmentNum}",
                ResidentName = GetStringSafe(reader, "ResidentName", "Nguyễn Văn An"),
                NumberOfGuests = GetIntSafe(reader, "NumberOfGuests", 1),
                MaxCapacity = GetIntSafe(reader, "MaxCapacity", 20),
                IdCardNumber = GetStringSafe(reader, "IdCardNumber", "079095001234"),
                FeeText = "Miễn phí cư dân (Ruby Privilege)",
                Status = status,
                StatusText = status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase) ? "ĐÃ HỦY" : "ĐÃ XÁC NHẬN",
                TicketCodeText = $"QR - {bId} - {cleanDate} - {cleanApt}",
                QrData = $"QR-{bId}-{cleanDate}-{cleanApt}",
                AmenityImageUrl = GetNullableString(reader, "AmenityImageUrl"),
            };
        }

        return null;
    }

    private static string GetStringSafe(MySqlDataReader reader, string column, string defaultValue = "")
    {
        try
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? defaultValue : reader.GetString(ordinal);
        }
        catch
        {
            return defaultValue;
        }
    }

    private static int GetIntSafe(MySqlDataReader reader, string column, int defaultValue = 0)
    {
        try
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? defaultValue : reader.GetInt32(ordinal);
        }
        catch
        {
            return defaultValue;
        }
    }

    public async Task<AmenityBookingDetailDto?> GetLatestBookingDetailAsync(string residentId, CancellationToken cancellationToken = default)
    {
        residentId = string.IsNullOrWhiteSpace(residentId) ? "Res1" : residentId;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        const string sql = "SELECT Id FROM AmenityBookings WHERE ResidentId = @ResId ORDER BY StartTime DESC LIMIT 1;";
        await using var cmd = new MySqlCommand(sql, connection);
        cmd.Parameters.AddWithValue("@ResId", residentId);

        var bookingIdObj = await cmd.ExecuteScalarAsync(cancellationToken);
        if (bookingIdObj != null)
        {
            return await GetBookingDetailAsync(bookingIdObj.ToString()!, cancellationToken);
        }

        // Default mock detailed data matching DB fallback
        return new AmenityBookingDetailDto();
    }

    public async Task<string> CreateBookingAsync(CreateAmenityBookingRequest request, CancellationToken cancellationToken = default)
    {
        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        const string aptSql = "SELECT ApartmentId FROM ApartmentHistories WHERE ResidentId = @ResId AND IsCurrent = 1 LIMIT 1;";
        await using var aptCmd = new MySqlCommand(aptSql, connection);
        aptCmd.Parameters.AddWithValue("@ResId", request.ResidentId);
        var res = await aptCmd.ExecuteScalarAsync(cancellationToken);
        var apartmentId = res?.ToString() ?? "B1-F01-01";

        var bookingId = $"AB_{Guid.NewGuid().ToString("N")[..8]}";

        const string insertSql = """
            INSERT INTO AmenityBookings (Id, AmenityId, ResidentId, ApartmentId, StartTime, EndTime, NumberOfGuests, Status, CreatedAt)
            VALUES (@Id, @AmenityId, @ResidentId, @ApartmentId, @StartTime, @EndTime, @Guests, 'Confirmed', NOW(6));
            """;

        await using (var cmd = new MySqlCommand(insertSql, connection))
        {
            cmd.Parameters.AddWithValue("@Id", bookingId);
            cmd.Parameters.AddWithValue("@AmenityId", request.AmenityId);
            cmd.Parameters.AddWithValue("@ResidentId", request.ResidentId);
            cmd.Parameters.AddWithValue("@ApartmentId", apartmentId);
            cmd.Parameters.AddWithValue("@StartTime", request.StartTime);
            cmd.Parameters.AddWithValue("@EndTime", request.EndTime);
            cmd.Parameters.AddWithValue("@Guests", request.NumberOfGuests);

            await cmd.ExecuteNonQueryAsync(cancellationToken);
        }

        return bookingId;
    }

    public async Task<bool> CancelBookingAsync(string bookingId, CancellationToken cancellationToken = default)
    {
        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        const string updateSql = "UPDATE AmenityBookings SET Status = 'Cancelled' WHERE Id = @Id;";
        await using var cmd = new MySqlCommand(updateSql, connection);
        cmd.Parameters.AddWithValue("@Id", bookingId);

        var rows = await cmd.ExecuteNonQueryAsync(cancellationToken);
        return rows > 0;
    }

    private static string? GetNullableString(MySqlDataReader reader, string column) =>
        reader.IsDBNull(reader.GetOrdinal(column)) ? null : reader.GetString(column);
}
