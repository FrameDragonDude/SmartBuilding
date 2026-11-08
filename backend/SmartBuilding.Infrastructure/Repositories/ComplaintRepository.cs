using System.Data;
using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

public sealed class ComplaintRepository(MySqlConnectionFactory connectionFactory) : IComplaintRepository
{
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

        await using var connection = connectionFactory.CreateConnection();
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

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        if (!string.IsNullOrWhiteSpace(buildingId))
            command.Parameters.AddWithValue("@BuildingId", buildingId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new ComplaintSummaryMetrics(
                Convert.ToInt32(reader.GetInt64("TotalComplaints")),
                Convert.ToInt32(reader.GetDecimal("PendingCount")),
                Convert.ToInt32(reader.GetDecimal("AssignedCount")),
                Convert.ToInt32(reader.GetDecimal("ProcessingCount")),
                Convert.ToInt32(reader.GetDecimal("ResolvedCount")),
                Convert.ToInt32(reader.GetDecimal("ClosedCount")));
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

        await using var connection = connectionFactory.CreateConnection();
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
        const string sql = """
            INSERT INTO ComplaintRequests (Id, ResidentId, ApartmentId, Category, Title, Content, AttachedImageUrl, Status, CreatedAt)
            VALUES (@Id, @ResidentId, @ApartmentId, @Category, @Title, @Content, @AttachedImageUrl, 'Pending', NOW(6));
            """;

        var id = Guid.NewGuid().ToString();
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        command.Parameters.AddWithValue("@Id", id);
        command.Parameters.AddWithValue("@ResidentId", request.ResidentId);
        command.Parameters.AddWithValue("@ApartmentId", request.ApartmentId);
        command.Parameters.AddWithValue("@Category", request.Category);
        command.Parameters.AddWithValue("@Title", request.Title);
        command.Parameters.AddWithValue("@Content", request.Content);
        command.Parameters.AddWithValue("@AttachedImageUrl", (object?)request.AttachedImageUrl ?? DBNull.Value);

        await command.ExecuteNonQueryAsync(cancellationToken);
        return id;
    }

    public async Task<bool> AssignComplaintAsync(
        AssignComplaintRequest request,
        CancellationToken cancellationToken)
    {
        const string sql = """
            UPDATE ComplaintRequests
            SET Status = 'Assigned'
            WHERE Id = @Id;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        command.Parameters.AddWithValue("@Id", request.ComplaintId);
        var rows = await command.ExecuteNonQueryAsync(cancellationToken);
        return rows > 0;
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

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        command.Parameters.AddWithValue("@Id", request.ComplaintId);
        command.Parameters.AddWithValue("@ResolvedImageUrl", request.ResolvedImageUrl);

        var rows = await command.ExecuteNonQueryAsync(cancellationToken);
        return rows > 0;
    }

    public async Task<bool> UpdateStatusAsync(
        string complaintId,
        string status,
        CancellationToken cancellationToken)
    {
        var sql = """
            UPDATE ComplaintRequests
            SET Status = @Status,
                ResolvedAt = (CASE WHEN @Status IN ('Resolved', 'Closed') AND ResolvedAt IS NULL THEN NOW(6) ELSE ResolvedAt END)
            WHERE Id = @Id;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);

        command.Parameters.AddWithValue("@Id", complaintId);
        command.Parameters.AddWithValue("@Status", status);

        var rows = await command.ExecuteNonQueryAsync(cancellationToken);
        return rows > 0;
    }
}
