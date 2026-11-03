using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

public class ComplaintRepository : IComplaintRepository
{
    private readonly MySqlConnectionFactory _connectionFactory;

    public ComplaintRepository(MySqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<ComplaintSummaryDataDto> GetComplaintsAsync(
        string? residentId,
        string? status,
        string? category,
        CancellationToken cancellationToken = default)
    {
        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        var result = new ComplaintSummaryDataDto();

        const string sql = """
            SELECT
                c.Id,
                a.ApartmentNumber,
                c.Category,
                c.Title,
                c.Content,
                c.AttachedImageUrl,
                c.ResolvedImageUrl,
                c.Status,
                DATE_FORMAT(c.CreatedAt, '%d/%m/%Y %H:%i') AS CreatedAt,
                DATE_FORMAT(c.ResolvedAt, '%d/%m/%Y %H:%i') AS ResolvedAt
            FROM ComplaintRequests c
            JOIN Apartments a ON a.Id = c.ApartmentId
            WHERE (@ResidentId IS NULL OR @ResidentId = '' OR c.ResidentId = @ResidentId)
              AND (@Status IS NULL OR @Status = '' OR @Status = 'All' OR LOWER(c.Status) = LOWER(@Status))
              AND (@Category IS NULL OR @Category = '' OR LOWER(c.Category) = LOWER(@Category))
            ORDER BY c.CreatedAt DESC;
            """;

        await using (var cmd = new MySqlCommand(sql, connection))
        {
            cmd.Parameters.AddWithValue("@ResidentId", residentId ?? "");
            cmd.Parameters.AddWithValue("@Status", status ?? "");
            cmd.Parameters.AddWithValue("@Category", category ?? "");

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                var st = reader.GetString("Status");
                result.TotalCount++;

                if (st == "Pending") result.PendingCount++;
                else if (st == "Assigned" || st == "Processing") result.ProcessingCount++;
                else if (st == "Resolved" || st == "Closed") result.ResolvedCount++;

                result.Complaints.Add(new ComplaintListItemDto
                {
                    Id = reader.GetString("Id"),
                    ApartmentNumber = reader.GetString("ApartmentNumber"),
                    Category = reader.GetString("Category"),
                    Title = reader.GetString("Title"),
                    Content = reader.GetString("Content"),
                    AttachedImageUrl = GetNullableString(reader, "AttachedImageUrl"),
                    ResolvedImageUrl = GetNullableString(reader, "ResolvedImageUrl"),
                    Status = st,
                    CreatedAt = reader.GetString("CreatedAt"),
                    ResolvedAt = GetNullableString(reader, "ResolvedAt")
                });
            }
        }

        return result;
    }

    public async Task<string> CreateComplaintAsync(
        CreateComplaintApiRequest request,
        CancellationToken cancellationToken = default)
    {
        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        var id = $"CR{Guid.NewGuid().ToString("N")[..6].ToUpper()}";

        var apartmentId = request.ApartmentId;
        if (string.IsNullOrWhiteSpace(apartmentId))
        {
            const string aptSql = "SELECT ApartmentId FROM ApartmentHistories WHERE ResidentId = @ResId AND IsCurrent = 1 LIMIT 1;";
            await using var cmd = new MySqlCommand(aptSql, connection);
            cmd.Parameters.AddWithValue("@ResId", request.ResidentId);
            var res = await cmd.ExecuteScalarAsync(cancellationToken);
            apartmentId = res?.ToString() ?? "B1-F01-01";
        }

        const string insertSql = """
            INSERT INTO ComplaintRequests (Id, ResidentId, ApartmentId, Category, Title, Content, AttachedImageUrl, Status, CreatedAt)
            VALUES (@Id, @ResidentId, @ApartmentId, @Category, @Title, @Content, @Image, 'Pending', NOW(6));
            """;

        await using (var cmd = new MySqlCommand(insertSql, connection))
        {
            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@ResidentId", request.ResidentId);
            cmd.Parameters.AddWithValue("@ApartmentId", apartmentId);
            cmd.Parameters.AddWithValue("@Category", request.Category);
            cmd.Parameters.AddWithValue("@Title", request.Title.Trim());
            cmd.Parameters.AddWithValue("@Content", request.Content.Trim());
            cmd.Parameters.AddWithValue("@Image", (object?)request.AttachedImageUrl ?? DBNull.Value);

            await cmd.ExecuteNonQueryAsync(cancellationToken);
        }

        return id;
    }

    private static string? GetNullableString(MySqlDataReader reader, string column) =>
        reader.IsDBNull(reader.GetOrdinal(column)) ? null : reader.GetString(column);
}
