using System.Data;
using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

public sealed class ResidentRepository(MySqlConnectionFactory connectionFactory) : IResidentRepository
{
    public async Task<IReadOnlyList<BuildingOption>> GetBuildingsAsync(CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT b.Id, b.BuildingCode, b.Name, b.TotalFloors, b.TotalBasements, b.Address,
                   COUNT(a.Id) AS TotalApartments
            FROM Buildings b
            LEFT JOIN Floors f ON f.BuildingId = b.Id
            LEFT JOIN Apartments a ON a.FloorId = f.Id
            GROUP BY b.Id, b.BuildingCode, b.Name, b.TotalFloors, b.TotalBasements, b.Address
            ORDER BY b.BuildingCode;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var result = new List<BuildingOption>();

        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new BuildingOption(
                reader.GetString("Id"),
                reader.GetString("BuildingCode"),
                reader.GetString("Name"),
                reader.GetInt32("TotalFloors"),
                reader.GetInt32("TotalBasements"),
                reader.GetString("Address"),
                Convert.ToInt32(reader.GetInt64("TotalApartments"))));
        }

        return result;
    }

    public async Task<IReadOnlyList<ResidentListItem>> GetListAsync(
        string? search,
        string? status,
        string? contractType,
        string? buildingId,
        CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT a.Id ApartmentId, a.ApartmentNumber, a.Status ApartmentStatus,
                   r.Id ResidentId, r.FullName, r.PhoneNumber, r.Email, ah.ContractType
            FROM Apartments a
            JOIN Floors f ON f.Id = a.FloorId
            LEFT JOIN ApartmentHistories ah ON ah.ApartmentId = a.Id AND ah.IsCurrent = 1
            LEFT JOIN Residents r ON r.Id = ah.ResidentId
            WHERE (@search IS NULL OR @search = '' OR a.ApartmentNumber LIKE CONCAT('%', @search, '%')
                OR r.FullName LIKE CONCAT('%', @search, '%') OR r.PhoneNumber LIKE CONCAT('%', @search, '%'))
              AND (@status IS NULL OR @status = '' OR @status = 'All' OR a.Status = @status)
              AND (@contractType IS NULL OR @contractType = '' OR @contractType = 'All' OR ah.ContractType = @contractType)
              AND (@buildingId IS NULL OR @buildingId = '' OR @buildingId = 'All' OR f.BuildingId = @buildingId)
            ORDER BY a.ApartmentNumber LIMIT 200;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@search", string.IsNullOrWhiteSpace(search) ? DBNull.Value : search.Trim());
        command.Parameters.AddWithValue("@status", string.IsNullOrWhiteSpace(status) ? DBNull.Value : status.Trim());
        command.Parameters.AddWithValue("@contractType", string.IsNullOrWhiteSpace(contractType) ? DBNull.Value : contractType.Trim());
        command.Parameters.AddWithValue("@buildingId", string.IsNullOrWhiteSpace(buildingId) ? DBNull.Value : buildingId.Trim());

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var result = new List<ResidentListItem>();

        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new ResidentListItem(
                reader.GetString("ApartmentId"),
                reader.GetString("ApartmentNumber"),
                reader.GetString("ApartmentStatus"),
                GetNullableString(reader, "ResidentId"),
                GetNullableString(reader, "FullName"),
                GetNullableString(reader, "PhoneNumber"),
                GetNullableString(reader, "Email"),
                GetNullableString(reader, "ContractType")));
        }

        return result;
    }

    public async Task<ResidentDetail?> GetDetailAsync(string apartmentId, CancellationToken cancellationToken)
    {
        const string baseSql = """
            SELECT a.Id ApartmentId, a.ApartmentNumber, a.Area, a.RoomsCount, a.BathroomsCount, a.Status ApartmentStatus,
                   f.FloorNumber, f.Description AS FloorDescription, b.Name AS BuildingName,
                   r.Id ResidentId, r.FullName, r.IdentityCardNumber, r.PhoneNumber, r.Email, r.DateOfBirth, r.Gender, r.AvatarUrl, r.CreatedAt ResidentCreatedAt,
                   ah.ContractType, ah.StartDate AS ContractStartDate, ah.EndDate AS ContractEndDate
            FROM Apartments a
            JOIN Floors f ON f.Id = a.FloorId
            JOIN Buildings b ON b.Id = f.BuildingId
            LEFT JOIN ApartmentHistories ah ON ah.ApartmentId = a.Id AND ah.IsCurrent = 1
            LEFT JOIN Residents r ON r.Id = ah.ResidentId
            WHERE a.Id = @ApartmentId OR a.ApartmentNumber = @ApartmentId
            LIMIT 1;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        string targetApartmentId;
        string? targetResidentId;
        ResidentDetail baseDetail;

        await using (var cmd = new MySqlCommand(baseSql, connection))
        {
            cmd.Parameters.AddWithValue("@ApartmentId", apartmentId);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            if (!await reader.ReadAsync(cancellationToken))
            {
                return null;
            }

            targetApartmentId = reader.GetString("ApartmentId");
            targetResidentId = GetNullableString(reader, "ResidentId");

            baseDetail = new ResidentDetail(
                targetResidentId,
                GetNullableString(reader, "FullName"),
                GetNullableString(reader, "IdentityCardNumber"),
                GetNullableString(reader, "PhoneNumber"),
                GetNullableString(reader, "Email"),
                GetNullableDateTime(reader, "DateOfBirth"),
                GetNullableString(reader, "Gender"),
                GetNullableString(reader, "AvatarUrl"),
                GetNullableDateTime(reader, "ResidentCreatedAt"),
                targetApartmentId,
                reader.GetString("ApartmentNumber"),
                reader.GetDecimal("Area"),
                reader.GetInt32("RoomsCount"),
                reader.GetInt32("BathroomsCount"),
                reader.GetString("ApartmentStatus"),
                GetNullableString(reader, "FloorDescription"),
                GetNullableString(reader, "BuildingName"),
                GetNullableString(reader, "ContractType"),
                GetNullableDateTime(reader, "ContractStartDate"),
                GetNullableDateTime(reader, "ContractEndDate"),
                [],
                [],
                []);
        }

        // Vehicles
        var vehicles = new List<VehicleDto>();
        const string vehicleSql = """
            SELECT Id, VehicleType, LicensePlate, RfidCardCode, Brand
            FROM Vehicles
            WHERE ApartmentId = @ApartmentId OR (@ResidentId IS NOT NULL AND ResidentId = @ResidentId)
            ORDER BY LicensePlate;
            """;
        await using (var cmd = new MySqlCommand(vehicleSql, connection))
        {
            cmd.Parameters.AddWithValue("@ApartmentId", targetApartmentId);
            cmd.Parameters.AddWithValue("@ResidentId", (object?)targetResidentId ?? DBNull.Value);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                vehicles.Add(new VehicleDto(
                    reader.GetString("Id"),
                    reader.GetString("VehicleType"),
                    reader.GetString("LicensePlate"),
                    reader.GetString("RfidCardCode"),
                    GetNullableString(reader, "Brand")));
            }
        }

        // Documents
        var documents = new List<DocumentDto>();
        if (!string.IsNullOrEmpty(targetResidentId))
        {
            const string docSql = """
                SELECT Id, DocumentType, DocumentNumber, IssuedDate, IssuedPlace, AttachmentUrl, VerificationStatus
                FROM ResidentDocuments
                WHERE ResidentId = @ResidentId
                ORDER BY UploadedAt DESC;
                """;
            await using var cmd = new MySqlCommand(docSql, connection);
            cmd.Parameters.AddWithValue("@ResidentId", targetResidentId);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                documents.Add(new DocumentDto(
                    reader.GetString("Id"),
                    reader.GetString("DocumentType"),
                    GetNullableString(reader, "DocumentNumber"),
                    GetNullableDateTime(reader, "IssuedDate"),
                    GetNullableString(reader, "IssuedPlace"),
                    reader.GetString("AttachmentUrl"),
                    reader.GetString("VerificationStatus")));
            }
        }

        // Invoices
        var invoices = new List<InvoiceDto>();
        const string invoiceSql = """
            SELECT Id, InvoiceCode, BillingMonth, BillingYear, TotalAmount, PaidAmount, Status, DueDate
            FROM MonthlyInvoices
            WHERE ApartmentId = @ApartmentId
            ORDER BY BillingYear DESC, BillingMonth DESC
            LIMIT 6;
            """;
        await using (var cmd = new MySqlCommand(invoiceSql, connection))
        {
            cmd.Parameters.AddWithValue("@ApartmentId", targetApartmentId);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                invoices.Add(new InvoiceDto(
                    reader.GetString("Id"),
                    reader.GetString("InvoiceCode"),
                    reader.GetInt32("BillingMonth"),
                    reader.GetInt32("BillingYear"),
                    reader.GetDecimal("TotalAmount"),
                    reader.GetDecimal("PaidAmount"),
                    reader.GetString("Status"),
                    reader.GetDateTime("DueDate")));
            }
        }

        return baseDetail with
        {
            Vehicles = vehicles,
            Documents = documents,
            Invoices = invoices
        };
    }

    public async Task<ResidentSummaryMetrics> GetMetricsAsync(string? buildingId, CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT 
                COUNT(a.Id) AS TotalApartments,
                COALESCE(SUM(CASE WHEN a.Status = 'Occupied' THEN 1 ELSE 0 END), 0) AS OccupiedApartments,
                COALESCE(SUM(CASE WHEN a.Status = 'Available' THEN 1 ELSE 0 END), 0) AS AvailableApartments,
                COALESCE((SELECT COUNT(DISTINCT ah2.ResidentId)
                          FROM ApartmentHistories ah2
                          JOIN Apartments a2 ON a2.Id = ah2.ApartmentId
                          JOIN Floors f2 ON f2.Id = a2.FloorId
                          WHERE ah2.IsCurrent = 1
                            AND (@buildingId IS NULL OR @buildingId = '' OR @buildingId = 'All' OR f2.BuildingId = @buildingId)), 0) AS TotalResidents,
                COALESCE((SELECT COUNT(*)
                          FROM ResidentDocuments rd
                          JOIN Residents r3 ON r3.Id = rd.ResidentId
                          JOIN ApartmentHistories ah3 ON ah3.ResidentId = r3.Id AND ah3.IsCurrent = 1
                          JOIN Apartments a3 ON a3.Id = ah3.ApartmentId
                          JOIN Floors f3 ON f3.Id = a3.FloorId
                          WHERE rd.VerificationStatus = 'Pending'
                            AND (@buildingId IS NULL OR @buildingId = '' OR @buildingId = 'All' OR f3.BuildingId = @buildingId)), 0) AS PendingApprovals
            FROM Apartments a
            JOIN Floors f ON f.Id = a.FloorId
            WHERE (@buildingId IS NULL OR @buildingId = '' OR @buildingId = 'All' OR f.BuildingId = @buildingId);
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@buildingId", string.IsNullOrWhiteSpace(buildingId) ? DBNull.Value : buildingId.Trim());
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);

        if (await reader.ReadAsync(cancellationToken))
        {
            return new ResidentSummaryMetrics(
                reader.GetInt32("TotalApartments"),
                Convert.ToInt32(reader.GetValue(reader.GetOrdinal("OccupiedApartments"))),
                Convert.ToInt32(reader.GetValue(reader.GetOrdinal("AvailableApartments"))),
                Convert.ToInt32(reader.GetValue(reader.GetOrdinal("TotalResidents"))),
                Convert.ToInt32(reader.GetValue(reader.GetOrdinal("PendingApprovals"))));
        }

        return new ResidentSummaryMetrics(0, 0, 0, 0, 0);
    }

    public async Task<IReadOnlyList<ApartmentOption>> GetApartmentsAsync(string? buildingId, CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT a.Id, a.ApartmentNumber, a.Status, a.Area, f.FloorNumber, b.Name AS BuildingName
            FROM Apartments a
            JOIN Floors f ON f.Id = a.FloorId
            JOIN Buildings b ON b.Id = f.BuildingId
            WHERE (@buildingId IS NULL OR @buildingId = '' OR @buildingId = 'All' OR b.Id = @buildingId)
            ORDER BY (CASE WHEN a.Status = 'Available' THEN 0 ELSE 1 END), a.ApartmentNumber ASC;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@buildingId", string.IsNullOrWhiteSpace(buildingId) ? DBNull.Value : buildingId.Trim());
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var result = new List<ApartmentOption>();

        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new ApartmentOption(
                reader.GetString("Id"),
                reader.GetString("ApartmentNumber"),
                reader.GetString("Status"),
                reader.GetDecimal("Area"),
                reader.GetInt32("FloorNumber"),
                reader.GetString("BuildingName")));
        }

        return result;
    }

    public async Task<string> CreateResidentAsync(CreateResidentRequest request, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var transaction = await connection.BeginTransactionAsync(cancellationToken);

        try
        {
            // Check if resident already exists by CCCD
            string residentId;
            const string checkSql = "SELECT Id FROM Residents WHERE IdentityCardNumber = @CCCD LIMIT 1;";
            await using (var checkCmd = new MySqlCommand(checkSql, connection, transaction))
            {
                checkCmd.Parameters.AddWithValue("@CCCD", request.IdentityCardNumber.Trim());
                var existingId = await checkCmd.ExecuteScalarAsync(cancellationToken);
                if (existingId != null && existingId != DBNull.Value)
                {
                    residentId = existingId.ToString()!;
                    // Update contact info
                    const string updateResSql = """
                        UPDATE Residents
                        SET FullName = @FullName, PhoneNumber = @PhoneNumber, Email = @Email,
                            DateOfBirth = @DateOfBirth, Gender = @Gender
                        WHERE Id = @ResidentId;
                        """;
                    await using var updateCmd = new MySqlCommand(updateResSql, connection, transaction);
                    updateCmd.Parameters.AddWithValue("@ResidentId", residentId);
                    updateCmd.Parameters.AddWithValue("@FullName", request.FullName.Trim());
                    updateCmd.Parameters.AddWithValue("@PhoneNumber", request.PhoneNumber.Trim());
                    updateCmd.Parameters.AddWithValue("@Email", (object?)request.Email?.Trim() ?? DBNull.Value);
                    updateCmd.Parameters.AddWithValue("@DateOfBirth", request.DateOfBirth.ToString("yyyy-MM-dd"));
                    updateCmd.Parameters.AddWithValue("@Gender", request.Gender);
                    await updateCmd.ExecuteNonQueryAsync(cancellationToken);
                }
                else
                {
                    residentId = "Res" + Guid.NewGuid().ToString("N")[..8];
                    const string insertResSql = """
                        INSERT INTO Residents (Id, FullName, IdentityCardNumber, PhoneNumber, Email, DateOfBirth, Gender, CreatedAt)
                        VALUES (@Id, @FullName, @IdentityCardNumber, @PhoneNumber, @Email, @DateOfBirth, @Gender, NOW(6));
                        """;
                    await using var insertCmd = new MySqlCommand(insertResSql, connection, transaction);
                    insertCmd.Parameters.AddWithValue("@Id", residentId);
                    insertCmd.Parameters.AddWithValue("@FullName", request.FullName.Trim());
                    insertCmd.Parameters.AddWithValue("@IdentityCardNumber", request.IdentityCardNumber.Trim());
                    insertCmd.Parameters.AddWithValue("@PhoneNumber", request.PhoneNumber.Trim());
                    insertCmd.Parameters.AddWithValue("@Email", (object?)request.Email?.Trim() ?? DBNull.Value);
                    insertCmd.Parameters.AddWithValue("@DateOfBirth", request.DateOfBirth.ToString("yyyy-MM-dd"));
                    insertCmd.Parameters.AddWithValue("@Gender", request.Gender);
                    await insertCmd.ExecuteNonQueryAsync(cancellationToken);
                }
            }

            // Deactivate previous active contracts for this apartment
            const string deactivateSql = "UPDATE ApartmentHistories SET IsCurrent = 0 WHERE ApartmentId = @ApartmentId;";
            await using (var deactCmd = new MySqlCommand(deactivateSql, connection, transaction))
            {
                deactCmd.Parameters.AddWithValue("@ApartmentId", request.ApartmentId);
                await deactCmd.ExecuteNonQueryAsync(cancellationToken);
            }

            // Insert new contract history
            var historyId = "AH" + Guid.NewGuid().ToString("N")[..8];
            const string insertHistSql = """
                INSERT INTO ApartmentHistories (Id, ApartmentId, ResidentId, ContractType, StartDate, IsCurrent)
                VALUES (@Id, @ApartmentId, @ResidentId, @ContractType, @StartDate, 1);
                """;
            await using (var histCmd = new MySqlCommand(insertHistSql, connection, transaction))
            {
                histCmd.Parameters.AddWithValue("@Id", historyId);
                histCmd.Parameters.AddWithValue("@ApartmentId", request.ApartmentId);
                histCmd.Parameters.AddWithValue("@ResidentId", residentId);
                histCmd.Parameters.AddWithValue("@ContractType", request.ContractType);
                histCmd.Parameters.AddWithValue("@StartDate", request.StartDate.ToString("yyyy-MM-dd"));
                await histCmd.ExecuteNonQueryAsync(cancellationToken);
            }

            // Mark apartment as Occupied
            const string updateAptSql = "UPDATE Apartments SET Status = 'Occupied' WHERE Id = @ApartmentId;";
            await using (var aptCmd = new MySqlCommand(updateAptSql, connection, transaction))
            {
                aptCmd.Parameters.AddWithValue("@ApartmentId", request.ApartmentId);
                await aptCmd.ExecuteNonQueryAsync(cancellationToken);
            }

            await transaction.CommitAsync(cancellationToken);
            return residentId;
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }
    }

    private static string? GetNullableString(MySqlDataReader reader, string column) =>
        reader.IsDBNull(reader.GetOrdinal(column)) ? null : reader.GetString(column);

    private static DateTime? GetNullableDateTime(MySqlDataReader reader, string column) =>
        reader.IsDBNull(reader.GetOrdinal(column)) ? null : reader.GetDateTime(column);
}
