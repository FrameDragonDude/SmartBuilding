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
