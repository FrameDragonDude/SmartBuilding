using System.Data;
using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

/// <summary>
/// Repository quản lý toàn bộ nghiệp vụ hóa đơn, thu phí, đối soát ngân hàng/UNC và lãi phạt
/// </summary>
public sealed class InvoiceRepository(MySqlConnectionFactory connectionFactory) : IInvoiceRepository
{
    public async Task<IReadOnlyList<InvoiceListItem>> GetInvoicesAsync(
        string? search,
        string? filterTab,
        int? month,
        int? year,
        string? buildingId,
        CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT 
                i.Id, i.InvoiceCode, i.ApartmentId, a.ApartmentNumber, r.FullName AS ResidentName, r.PhoneNumber,
                i.BillingMonth, i.BillingYear, i.TotalAmount, i.PaidAmount, i.Status, i.DueDate,
                COALESCE(mg.Fee, 0) AS ManagementFee,
                COALESCE(el.Fee, 0) AS ElectricityFee,
                COALESCE(wa.Fee, 0) AS WaterFee,
                COALESCE(pk.Fee, 0) AS ParkingFee,
                GREATEST(0, DATEDIFF(CURRENT_DATE(), i.DueDate)) AS OverdueDays,
                COALESCE(pen.PenaltyAmount, 0) AS PenaltyAmount
            FROM MonthlyInvoices i
            JOIN Apartments a ON a.Id = i.ApartmentId
            JOIN Floors f ON f.Id = a.FloorId
            LEFT JOIN ApartmentHistories ah ON ah.ApartmentId = a.Id AND ah.IsCurrent = 1
            LEFT JOIN Residents r ON r.Id = ah.ResidentId
            LEFT JOIN (SELECT InvoiceId, SUM(LineTotal) AS Fee FROM InvoiceDetails WHERE ItemType = 'ManagementFee' GROUP BY InvoiceId) mg ON mg.InvoiceId = i.Id
            LEFT JOIN (SELECT InvoiceId, SUM(LineTotal) AS Fee FROM InvoiceDetails WHERE ItemType = 'Electricity' GROUP BY InvoiceId) el ON el.InvoiceId = i.Id
            LEFT JOIN (SELECT InvoiceId, SUM(LineTotal) AS Fee FROM InvoiceDetails WHERE ItemType = 'Water' GROUP BY InvoiceId) wa ON wa.InvoiceId = i.Id
            LEFT JOIN (SELECT InvoiceId, SUM(LineTotal) AS Fee FROM InvoiceDetails WHERE ItemType = 'ParkingFee' GROUP BY InvoiceId) pk ON pk.InvoiceId = i.Id
            LEFT JOIN (SELECT InvoiceId, SUM(PenaltyAmount) AS PenaltyAmount FROM LatePaymentPenalties WHERE IsResolved = 0 GROUP BY InvoiceId) pen ON pen.InvoiceId = i.Id
            WHERE (@search IS NULL OR @search = '' OR i.InvoiceCode LIKE CONCAT('%', @search, '%') 
                   OR a.ApartmentNumber LIKE CONCAT('%', @search, '%') OR r.FullName LIKE CONCAT('%', @search, '%'))
              AND (@month IS NULL OR i.BillingMonth = @month)
              AND (@year IS NULL OR i.BillingYear = @year)
              AND (@buildingId IS NULL OR @buildingId = '' OR @buildingId = 'All' OR f.BuildingId = @buildingId)
              AND (
                   @filterTab = 'All' OR @filterTab IS NULL OR @filterTab = ''
                   OR (@filterTab = 'PendingUNC' AND (SELECT COUNT(*) FROM Payments p WHERE p.InvoiceId = i.Id AND p.Status = 'Pending') > 0)
                   OR (@filterTab = 'Overdue' AND (i.Status = 'Overdue' OR (i.Status != 'Paid' AND i.DueDate < CURRENT_DATE())))
                   OR (@filterTab = 'Paid' AND i.Status = 'Paid')
              )
            ORDER BY i.BillingYear DESC, i.BillingMonth DESC, a.ApartmentNumber ASC LIMIT 200;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@search", string.IsNullOrWhiteSpace(search) ? DBNull.Value : search.Trim());
        command.Parameters.AddWithValue("@filterTab", string.IsNullOrWhiteSpace(filterTab) ? "All" : filterTab.Trim());
        command.Parameters.AddWithValue("@month", (object?)month ?? DBNull.Value);
        command.Parameters.AddWithValue("@year", (object?)year ?? DBNull.Value);
        command.Parameters.AddWithValue("@buildingId", string.IsNullOrWhiteSpace(buildingId) ? DBNull.Value : buildingId.Trim());

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var result = new List<InvoiceListItem>();

        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new InvoiceListItem(
                reader.GetString("Id"),
                reader.GetString("InvoiceCode"),
                reader.GetString("ApartmentId"),
                reader.GetString("ApartmentNumber"),
                GetNullableString(reader, "ResidentName"),
                GetNullableString(reader, "PhoneNumber"),
                reader.GetInt32("BillingMonth"),
                reader.GetInt32("BillingYear"),
                reader.GetDecimal("ManagementFee"),
                reader.GetDecimal("ElectricityFee"),
                reader.GetDecimal("WaterFee"),
                reader.GetDecimal("ParkingFee"),
                reader.GetDecimal("TotalAmount"),
                reader.GetDecimal("PaidAmount"),
                reader.GetString("Status"),
                reader.GetDateTime("DueDate"),
                Convert.ToInt32(reader["OverdueDays"]),
                reader.GetDecimal("PenaltyAmount")));
        }

        return result;
    }

    public async Task<InvoiceSummaryMetrics> GetSummaryMetricsAsync(int? month, int? year, string? buildingId, CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT 
                COALESCE(SUM(i.TotalAmount), 0) AS TotalAmount,
                COALESCE(SUM(i.PaidAmount), 0) AS PaidAmount,
                COALESCE(SUM(CASE WHEN i.Status = 'Unpaid' OR i.Status = 'PartiallyPaid' THEN (i.TotalAmount - i.PaidAmount) ELSE 0 END), 0) AS PendingAmount,
                COALESCE(SUM(CASE WHEN i.Status = 'Overdue' OR (i.Status != 'Paid' AND i.DueDate < CURRENT_DATE()) THEN (i.TotalAmount - i.PaidAmount) ELSE 0 END), 0) AS OverdueAmount,
                (SELECT COALESCE(SUM(Amount), 0) FROM Payments WHERE PaymentMethod = 'Cash' AND Status = 'Success') AS CashFundAmount,
                COUNT(i.Id) AS TotalInvoices,
                COALESCE(SUM(CASE WHEN i.Status = 'Paid' THEN 1 ELSE 0 END), 0) AS PaidCount,
                COALESCE(SUM(CASE WHEN i.Status = 'Unpaid' OR i.Status = 'PartiallyPaid' THEN 1 ELSE 0 END), 0) AS PendingCount,
                COALESCE(SUM(CASE WHEN i.Status = 'Overdue' OR (i.Status != 'Paid' AND i.DueDate < CURRENT_DATE()) THEN 1 ELSE 0 END), 0) AS OverdueCount
            FROM MonthlyInvoices i
            JOIN Apartments a ON a.Id = i.ApartmentId
            JOIN Floors f ON f.Id = a.FloorId
            WHERE (@month IS NULL OR i.BillingMonth = @month)
              AND (@year IS NULL OR i.BillingYear = @year)
              AND (@buildingId IS NULL OR @buildingId = '' OR @buildingId = 'All' OR f.BuildingId = @buildingId);
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@month", (object?)month ?? DBNull.Value);
        command.Parameters.AddWithValue("@year", (object?)year ?? DBNull.Value);
        command.Parameters.AddWithValue("@buildingId", string.IsNullOrWhiteSpace(buildingId) ? DBNull.Value : buildingId.Trim());

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new InvoiceSummaryMetrics(
                reader.GetDecimal("TotalAmount"),
                reader.GetDecimal("PaidAmount"),
                reader.GetDecimal("PendingAmount"),
                reader.GetDecimal("OverdueAmount"),
                reader.GetDecimal("CashFundAmount"),
                Convert.ToInt32(reader["TotalInvoices"]),
                Convert.ToInt32(reader["PaidCount"]),
                Convert.ToInt32(reader["PendingCount"]),
                Convert.ToInt32(reader["OverdueCount"]));
        }

        return new InvoiceSummaryMetrics(0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    public async Task<IReadOnlyList<PendingPaymentItem>> GetPendingPaymentsAsync(CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT p.Id AS PaymentId, p.InvoiceId, i.InvoiceCode, a.ApartmentNumber, r.FullName AS ResidentName,
                   p.TransactionCode, p.PaymentMethod, p.Amount, p.ProofReceiptUrl, p.PaymentDate, p.PayerNote
            FROM Payments p
            JOIN MonthlyInvoices i ON i.Id = p.InvoiceId
            JOIN Apartments a ON a.Id = i.ApartmentId
            LEFT JOIN ApartmentHistories ah ON ah.ApartmentId = a.Id AND ah.IsCurrent = 1
            LEFT JOIN Residents r ON r.Id = ah.ResidentId
            WHERE p.Status = 'Pending'
            ORDER BY p.PaymentDate DESC LIMIT 20;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var result = new List<PendingPaymentItem>();

        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new PendingPaymentItem(
                reader.GetString("PaymentId"),
                reader.GetString("InvoiceId"),
                reader.GetString("InvoiceCode"),
                reader.GetString("ApartmentNumber"),
                GetNullableString(reader, "ResidentName"),
                reader.GetString("TransactionCode"),
                reader.GetString("PaymentMethod"),
                reader.GetDecimal("Amount"),
                GetNullableString(reader, "ProofReceiptUrl"),
                reader.GetDateTime("PaymentDate"),
                GetNullableString(reader, "PayerNote")));
        }

        return result;
    }

    public async Task<IReadOnlyList<PenaltyItem>> GetPenaltiesAsync(CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT pen.Id AS PenaltyId, pen.InvoiceId, i.InvoiceCode, a.ApartmentNumber, r.FullName AS ResidentName,
                   pen.OverdueDays, (i.TotalAmount - i.PaidAmount) AS OriginalAmount, pen.PenaltyAmount, pen.Reason, pen.IsResolved
            FROM LatePaymentPenalties pen
            JOIN MonthlyInvoices i ON i.Id = pen.InvoiceId
            JOIN Apartments a ON a.Id = i.ApartmentId
            LEFT JOIN ApartmentHistories ah ON ah.ApartmentId = a.Id AND ah.IsCurrent = 1
            LEFT JOIN Residents r ON r.Id = ah.ResidentId
            WHERE pen.IsResolved = 0
            ORDER BY pen.OverdueDays DESC LIMIT 20;
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var result = new List<PenaltyItem>();

        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new PenaltyItem(
                reader.GetString("PenaltyId"),
                reader.GetString("InvoiceId"),
                reader.GetString("InvoiceCode"),
                reader.GetString("ApartmentNumber"),
                GetNullableString(reader, "ResidentName"),
                reader.GetInt32("OverdueDays"),
                reader.GetDecimal("OriginalAmount"),
                reader.GetDecimal("PenaltyAmount"),
                reader.GetString("Reason"),
                reader.GetBoolean("IsResolved")));
        }

        return result;
    }

    public async Task<RevenueStructure> GetRevenueStructureAsync(int? month, int? year, CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT 
                COALESCE(SUM(CASE WHEN id.ItemType = 'ManagementFee' THEN id.LineTotal ELSE 0 END), 0) AS ManagementTotal,
                COALESCE(SUM(CASE WHEN id.ItemType = 'Electricity' THEN id.LineTotal ELSE 0 END), 0) AS ElectricityTotal,
                COALESCE(SUM(CASE WHEN id.ItemType IN ('Water', 'ParkingFee') THEN id.LineTotal ELSE 0 END), 0) AS WaterAndParkingTotal,
                COALESCE(SUM(id.LineTotal), 0) AS GrandTotal
            FROM InvoiceDetails id
            JOIN MonthlyInvoices i ON i.Id = id.InvoiceId
            WHERE (@month IS NULL OR i.BillingMonth = @month)
              AND (@year IS NULL OR i.BillingYear = @year);
            """;

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var command = new MySqlCommand(sql, connection);
        command.Parameters.AddWithValue("@month", (object?)month ?? DBNull.Value);
        command.Parameters.AddWithValue("@year", (object?)year ?? DBNull.Value);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new RevenueStructure(
                reader.GetDecimal("ManagementTotal"),
                reader.GetDecimal("ElectricityTotal"),
                reader.GetDecimal("WaterAndParkingTotal"),
                reader.GetDecimal("GrandTotal"));
        }

        return new RevenueStructure(0, 0, 0, 0);
    }

    public async Task<bool> ApprovePaymentAsync(string paymentId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var tx = await connection.BeginTransactionAsync(cancellationToken);

        try
        {
            decimal amount = 0;
            string? invoiceId = null;

            const string getPaymentSql = "SELECT InvoiceId, Amount FROM Payments WHERE Id = @PaymentId;";
            await using (var getCmd = new MySqlCommand(getPaymentSql, connection, tx))
            {
                getCmd.Parameters.AddWithValue("@PaymentId", paymentId);
                await using var reader = await getCmd.ExecuteReaderAsync(cancellationToken);
                if (await reader.ReadAsync(cancellationToken))
                {
                    invoiceId = reader.GetString("InvoiceId");
                    amount = reader.GetDecimal("Amount");
                }
            }

            if (invoiceId == null) return false;

            // Update Payment to Success
            const string updatePaymentSql = "UPDATE Payments SET Status = 'Success' WHERE Id = @PaymentId;";
            await using (var updateCmd = new MySqlCommand(updatePaymentSql, connection, tx))
            {
                updateCmd.Parameters.AddWithValue("@PaymentId", paymentId);
                await updateCmd.ExecuteNonQueryAsync(cancellationToken);
            }

            // Update Invoice PaidAmount & Status
            const string updateInvoiceSql = """
                UPDATE MonthlyInvoices
                SET PaidAmount = LEAST(TotalAmount, PaidAmount + @Amount),
                    Status = CASE WHEN (PaidAmount + @Amount) >= TotalAmount THEN 'Paid' ELSE 'PartiallyPaid' END
                WHERE Id = @InvoiceId;
                """;
            await using (var invCmd = new MySqlCommand(updateInvoiceSql, connection, tx))
            {
                invCmd.Parameters.AddWithValue("@Amount", amount);
                invCmd.Parameters.AddWithValue("@InvoiceId", invoiceId);
                await invCmd.ExecuteNonQueryAsync(cancellationToken);
            }

            await tx.CommitAsync(cancellationToken);
            return true;
        }
        catch
        {
            await tx.RollbackAsync(cancellationToken);
            throw;
        }
    }

    public async Task<bool> RejectPaymentAsync(string paymentId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        const string sql = "UPDATE Payments SET Status = 'Failed' WHERE Id = @PaymentId;";
        await using var cmd = new MySqlCommand(sql, connection);
        cmd.Parameters.AddWithValue("@PaymentId", paymentId);
        var rows = await cmd.ExecuteNonQueryAsync(cancellationToken);
        return rows > 0;
    }

    public async Task<bool> WaivePenaltyAsync(string penaltyId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        const string sql = "UPDATE LatePaymentPenalties SET IsResolved = 1, Reason = CONCAT(Reason, ' [Đã duyệt miễn phạt]') WHERE Id = @PenaltyId;";
        await using var cmd = new MySqlCommand(sql, connection);
        cmd.Parameters.AddWithValue("@PenaltyId", penaltyId);
        var rows = await cmd.ExecuteNonQueryAsync(cancellationToken);
        return rows > 0;
    }

    public async Task<int> SendBatchRemindersAsync(CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        const string sql = """
            UPDATE MonthlyInvoices
            SET ReminderSent = 1, ReminderDate = NOW(6)
            WHERE Status IN ('Unpaid', 'PartiallyPaid', 'Overdue');
            """;
        await using var cmd = new MySqlCommand(sql, connection);
        return await cmd.ExecuteNonQueryAsync(cancellationToken);
    }

    public async Task<int> GenerateMonthlyInvoicesAsync(int month, int year, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var tx = await connection.BeginTransactionAsync(cancellationToken);

        try
        {
            // Find occupied apartments without invoices for this cycle
            const string aptSql = """
                SELECT a.Id, a.ApartmentNumber, a.Area
                FROM Apartments a
                WHERE a.Status = 'Occupied'
                  AND NOT EXISTS (
                      SELECT 1 FROM MonthlyInvoices mi 
                      WHERE mi.ApartmentId = a.Id AND mi.BillingMonth = @Month AND mi.BillingYear = @Year
                  );
                """;

            var apartmentsToBill = new List<(string Id, string Number, decimal Area)>();
            await using (var cmd = new MySqlCommand(aptSql, connection, tx))
            {
                cmd.Parameters.AddWithValue("@Month", month);
                cmd.Parameters.AddWithValue("@Year", year);
                await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
                while (await reader.ReadAsync(cancellationToken))
                {
                    apartmentsToBill.Add((
                        reader.GetString("Id"),
                        reader.GetString("ApartmentNumber"),
                        reader.GetDecimal("Area")));
                }
            }

            int count = 0;
            foreach (var (aptId, aptNumber, area) in apartmentsToBill)
            {
                var invoiceId = "Inv-" + Guid.NewGuid().ToString("N")[..8];
                var invoiceCode = $"INV-{year:0000}{month:00}-{aptNumber}";
                var dueDate = new DateTime(year, month, 15).AddMonths(1);
                var mgmtFee = Math.Round(area * 18000m, 2);
                var electFee = 450000m;
                var waterFee = 160000m;
                var total = mgmtFee + electFee + waterFee;

                const string insertInvSql = """
                    INSERT INTO MonthlyInvoices (Id, ApartmentId, InvoiceCode, BillingMonth, BillingYear, TotalAmount, PaidAmount, DueDate, Status, CreatedAt)
                    VALUES (@Id, @ApartmentId, @InvoiceCode, @BillingMonth, @BillingYear, @TotalAmount, 0, @DueDate, 'Unpaid', NOW(6));
                    """;
                await using (var invCmd = new MySqlCommand(insertInvSql, connection, tx))
                {
                    invCmd.Parameters.AddWithValue("@Id", invoiceId);
                    invCmd.Parameters.AddWithValue("@ApartmentId", aptId);
                    invCmd.Parameters.AddWithValue("@InvoiceCode", invoiceCode);
                    invCmd.Parameters.AddWithValue("@BillingMonth", month);
                    invCmd.Parameters.AddWithValue("@BillingYear", year);
                    invCmd.Parameters.AddWithValue("@TotalAmount", total);
                    invCmd.Parameters.AddWithValue("@DueDate", dueDate.ToString("yyyy-MM-dd"));
                    await invCmd.ExecuteNonQueryAsync(cancellationToken);
                }

                // Add Detail items
                const string detailSql = """
                    INSERT INTO InvoiceDetails (Id, InvoiceId, ItemType, Description, Quantity, UnitPrice, LineTotal)
                    VALUES 
                        (UUID(), @InvoiceId, 'ManagementFee', 'Phí quản lý căn hộ', @Area, 18000, @MgmtFee),
                        (UUID(), @InvoiceId, 'Electricity', 'Điện sinh hoạt tạm tính', 1, @ElectFee, @ElectFee),
                        (UUID(), @InvoiceId, 'Water', 'Nước sinh hoạt tạm tính', 1, @WaterFee, @WaterFee);
                    """;
                await using (var detailCmd = new MySqlCommand(detailSql, connection, tx))
                {
                    detailCmd.Parameters.AddWithValue("@InvoiceId", invoiceId);
                    detailCmd.Parameters.AddWithValue("@Area", area);
                    detailCmd.Parameters.AddWithValue("@MgmtFee", mgmtFee);
                    detailCmd.Parameters.AddWithValue("@ElectFee", electFee);
                    detailCmd.Parameters.AddWithValue("@WaterFee", waterFee);
                    await detailCmd.ExecuteNonQueryAsync(cancellationToken);
                }

                count++;
            }

            await tx.CommitAsync(cancellationToken);
            return count;
        }
        catch
        {
            await tx.RollbackAsync(cancellationToken);
            throw;
        }
    }

    private static string? GetNullableString(MySqlDataReader reader, string column) =>
        reader.IsDBNull(reader.GetOrdinal(column)) ? null : reader.GetString(column);
}
