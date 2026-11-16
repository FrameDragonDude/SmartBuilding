using System.Data;
using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

public sealed class ComplaintRepository(MySqlConnectionFactory connectionFactory) : IComplaintRepository
{
    private readonly MySqlConnectionFactory _connectionFactory = connectionFactory;

    #region Web Admin Methods (Long)

    public async Task<IReadOnlyList<ComplaintListItem>> GetListAsync(
        string? buildingId,
        string? category,
        string? status,
        string? search,
        CancellationToken cancellationToken)
    {
        var sql = """
            SELECT c.Id, c.ResidentId, r.FullName AS ResidentName, r.PhoneNumber,
                   c.ApartmentId, a.ApartmentNumber, b.Id AS BuildingId, b.Name AS BuildingName,
                   c.Category, c.Title, c.Content, c.AttachedImageUrl, c.ResolvedImageUrl,
                   c.Status, c.CreatedAt, c.ResolvedAt
            FROM ComplaintRequests c
            INNER JOIN Residents r ON r.Id = c.ResidentId
            INNER JOIN Apartments a ON a.Id = c.ApartmentId
            INNER JOIN Floors f ON f.Id = a.FloorId
            INNER JOIN Buildings b ON b.Id = f.BuildingId
            WHERE 1=1
            """;

        if (!string.IsNullOrWhiteSpace(buildingId))
            sql += " AND b.Id = @BuildingId";
        if (!string.IsNullOrWhiteSpace(category) && category != "All")
            sql += " AND c.Category = @Category";
        if (!string.IsNullOrWhiteSpace(status) && status != "All")
            sql += " AND c.Status = @Status";
        if (!string.IsNullOrWhiteSpace(search))
            sql += " AND (c.Title LIKE @Search OR c.Content LIKE @Search OR r.FullName LIKE @Search OR a.ApartmentNumber LIKE @Search)";

        sql += " ORDER BY c.CreatedAt DESC;";

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        if (!string.IsNullOrWhiteSpace(buildingId))
            command.Parameters.AddWithValue("@BuildingId", buildingId);
        if (!string.IsNullOrWhiteSpace(category) && category != "All")
            command.Parameters.AddWithValue("@Category", category);
        if (!string.IsNullOrWhiteSpace(status) && status != "All")
            command.Parameters.AddWithValue("@Status", status);
        if (!string.IsNullOrWhiteSpace(search))
            command.Parameters.AddWithValue("@Search", $"%{search}%");

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var list = new List<ComplaintListItem>();

        while (await reader.ReadAsync(cancellationToken))
        {
            list.Add(new ComplaintListItem(
                reader.GetString("Id"),
                reader.GetString("ResidentId"),
                reader.GetString("ResidentName"),
                reader.GetString("PhoneNumber"),
                reader.GetString("ApartmentId"),
                reader.GetString("ApartmentNumber"),
                reader.GetString("BuildingId"),
                reader.GetString("BuildingName"),
                reader.GetString("Category"),
                reader.GetString("Title"),
                reader.GetString("Content"),
                reader.IsDBNull(reader.GetOrdinal("AttachedImageUrl")) ? null : reader.GetString("AttachedImageUrl"),
                reader.IsDBNull(reader.GetOrdinal("ResolvedImageUrl")) ? null : reader.GetString("ResolvedImageUrl"),
                reader.GetString("Status"),
                reader.GetDateTime("CreatedAt"),
                reader.IsDBNull(reader.GetOrdinal("ResolvedAt")) ? null : reader.GetDateTime("ResolvedAt")));
        }

        return list;
    }

    public async Task<ComplaintSummaryMetrics> GetMetricsAsync(
        string? buildingId,
        CancellationToken cancellationToken)
    {
        var sql = """
            SELECT 
                COUNT(c.Id) AS TotalComplaints,
                SUM(CASE WHEN c.Status = 'Pending' THEN 1 ELSE 0 END) AS PendingCount,
                SUM(CASE WHEN c.Status = 'Assigned' THEN 1 ELSE 0 END) AS AssignedCount,
                SUM(CASE WHEN c.Status = 'Processing' THEN 1 ELSE 0 END) AS ProcessingCount,
                SUM(CASE WHEN c.Status = 'Resolved' THEN 1 ELSE 0 END) AS ResolvedCount,
                SUM(CASE WHEN c.Status = 'Closed' THEN 1 ELSE 0 END) AS ClosedCount
            FROM ComplaintRequests c
            INNER JOIN Apartments a ON a.Id = c.ApartmentId
            INNER JOIN Floors f ON f.Id = a.FloorId
            INNER JOIN Buildings b ON b.Id = f.BuildingId
            WHERE 1=1
            """;

        if (!string.IsNullOrWhiteSpace(buildingId))
            sql += " AND b.Id = @BuildingId";

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        if (!string.IsNullOrWhiteSpace(buildingId))
            command.Parameters.AddWithValue("@BuildingId", buildingId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new ComplaintSummaryMetrics(
                reader.IsDBNull(reader.GetOrdinal("TotalComplaints")) ? 0 : Convert.ToInt32(reader["TotalComplaints"]),
                reader.IsDBNull(reader.GetOrdinal("PendingCount")) ? 0 : Convert.ToInt32(reader["PendingCount"]),
                reader.IsDBNull(reader.GetOrdinal("AssignedCount")) ? 0 : Convert.ToInt32(reader["AssignedCount"]),
                reader.IsDBNull(reader.GetOrdinal("ProcessingCount")) ? 0 : Convert.ToInt32(reader["ProcessingCount"]),
                reader.IsDBNull(reader.GetOrdinal("ResolvedCount")) ? 0 : Convert.ToInt32(reader["ResolvedCount"]),
                reader.IsDBNull(reader.GetOrdinal("ClosedCount")) ? 0 : Convert.ToInt32(reader["ClosedCount"]));
        }

        return new ComplaintSummaryMetrics(0, 0, 0, 0, 0, 0);
    }

    public async Task<ComplaintListItem?> GetDetailAsync(
        string complaintId,
        CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT c.Id, c.ResidentId, r.FullName AS ResidentName, r.PhoneNumber,
                   c.ApartmentId, a.ApartmentNumber, b.Id AS BuildingId, b.Name AS BuildingName,
                   c.Category, c.Title, c.Content, c.AttachedImageUrl, c.ResolvedImageUrl,
                   c.Status, c.CreatedAt, c.ResolvedAt
            FROM ComplaintRequests c
            INNER JOIN Residents r ON r.Id = c.ResidentId
            INNER JOIN Apartments a ON a.Id = c.ApartmentId
            INNER JOIN Floors f ON f.Id = a.FloorId
            INNER JOIN Buildings b ON b.Id = f.BuildingId
            WHERE c.Id = @Id
            LIMIT 1;
            """;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@Id", complaintId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new ComplaintListItem(
                reader.GetString("Id"),
                reader.GetString("ResidentId"),
                reader.GetString("ResidentName"),
                reader.GetString("PhoneNumber"),
                reader.GetString("ApartmentId"),
                reader.GetString("ApartmentNumber"),
                reader.GetString("BuildingId"),
                reader.GetString("BuildingName"),
                reader.GetString("Category"),
                reader.GetString("Title"),
                reader.GetString("Content"),
                reader.IsDBNull(reader.GetOrdinal("AttachedImageUrl")) ? null : reader.GetString("AttachedImageUrl"),
                reader.IsDBNull(reader.GetOrdinal("ResolvedImageUrl")) ? null : reader.GetString("ResolvedImageUrl"),
                reader.GetString("Status"),
                reader.GetDateTime("CreatedAt"),
                reader.IsDBNull(reader.GetOrdinal("ResolvedAt")) ? null : reader.GetDateTime("ResolvedAt"));
        }

        return null;
    }

    public async Task<string> CreateComplaintAsync(
        CreateComplaintRequest request,
        CancellationToken cancellationToken)
    {
        const string checkSql = "SELECT COUNT(1) FROM Apartments WHERE Id = @AptId;";
        const string insertSql = """
            INSERT INTO ComplaintRequests (
                Id, ResidentId, ApartmentId, Category, Title, Content, AttachedImageUrl, Status, CreatedAt
            ) VALUES (
                @Id, @ResidentId, @ApartmentId, @Category, @Title, @Content, @AttachedImageUrl, 'Pending', NOW(6)
            );
            """;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using (var checkCmd = new MySqlCommand(checkSql, connection))
        {
            checkCmd.Parameters.AddWithValue("@AptId", request.ApartmentId);
            var exists = Convert.ToInt32(await checkCmd.ExecuteScalarAsync(cancellationToken));
            if (exists == 0)
                throw new InvalidOperationException($"Căn hộ mã {request.ApartmentId} không tồn tại trong hệ thống.");
        }

        var newId = $"CR-{DateTime.UtcNow:yyMMdd}-{Guid.NewGuid().ToString("N")[..4].ToUpper()}";

        await using var command = new MySqlCommand(insertSql, connection);
        command.Parameters.AddWithValue("@Id", newId);
        command.Parameters.AddWithValue("@ResidentId", request.ResidentId);
        command.Parameters.AddWithValue("@ApartmentId", request.ApartmentId);
        command.Parameters.AddWithValue("@Category", request.Category);
        command.Parameters.AddWithValue("@Title", request.Title);
        command.Parameters.AddWithValue("@Content", request.Content);
        command.Parameters.AddWithValue("@AttachedImageUrl", (object?)request.AttachedImageUrl ?? DBNull.Value);

        await command.ExecuteNonQueryAsync(cancellationToken);
        return newId;
    }

    public async Task<bool> AssignComplaintAsync(
        AssignComplaintRequest request,
        CancellationToken cancellationToken)
    {
        const string sql = """
            UPDATE ComplaintRequests
            SET Status = 'Assigned'
            WHERE Id = @Id AND Status IN ('Pending', 'Assigned');
            """;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@Id", request.ComplaintId);

        var affected = await command.ExecuteNonQueryAsync(cancellationToken);
        return affected > 0;
    }

    public async Task<bool> ResolveComplaintAsync(
        ResolveComplaintRequest request,
        CancellationToken cancellationToken)
    {
        const string sql = """
            UPDATE ComplaintRequests
            SET Status = 'Resolved',
                ResolvedImageUrl = @ResolvedImageUrl,
                ResolvedAt = NOW(6)
            WHERE Id = @Id;
            """;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@Id", request.ComplaintId);
        command.Parameters.AddWithValue("@ResolvedImageUrl", request.ResolvedImageUrl);

        var affected = await command.ExecuteNonQueryAsync(cancellationToken);
        return affected > 0;
    }

    public async Task<bool> UpdateStatusAsync(
        string complaintId,
        string status,
        CancellationToken cancellationToken)
    {
        const string sql = """
            UPDATE ComplaintRequests
            SET Status = @Status,
                ResolvedAt = CASE WHEN @Status IN ('Resolved', 'Closed') THEN NOW(6) ELSE ResolvedAt END
            WHERE Id = @Id;
            """;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@Id", complaintId);
        command.Parameters.AddWithValue("@Status", status);

        var affected = await command.ExecuteNonQueryAsync(cancellationToken);
        return affected > 0;
    }

    #endregion

    #region Mobile App Methods (Phong)

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

    #endregion
}
