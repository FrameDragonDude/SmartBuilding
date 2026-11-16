using MySqlConnector;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Application.Models;
using SmartBuilding.Infrastructure.Data;

namespace SmartBuilding.Infrastructure.Repositories;

public class HomeRepository : IHomeRepository
{
    private readonly MySqlConnectionFactory _connectionFactory;

    public HomeRepository(MySqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<HomeDataDto> GetHomeDataAsync(string? residentId, CancellationToken cancellationToken = default)
    {
        // Default to 'Res1' if residentId is not provided
        residentId = string.IsNullOrWhiteSpace(residentId) ? "Res1" : residentId;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        var homeData = new HomeDataDto();

        // 1. Resident Info
        const string residentSql = """
            SELECT
                r.Id AS ResidentId,
                r.FullName,
                a.ApartmentNumber,
                CONCAT('Tầng ', f.FloorNumber) AS FloorNumber,
                b.Name AS BuildingName,
                b.BuildingCode,
                a.Area,
                ah.ContractType,
                DATE_FORMAT(ah.StartDate, '%d/%m/%Y') AS StartDate,
                DATE_FORMAT(IFNULL(ah.EndDate, DATE_ADD(ah.StartDate, INTERVAL 3 YEAR)), '%d/%m/%Y') AS EndDate
            FROM Residents r
            JOIN ApartmentHistories ah ON ah.ResidentId = r.Id AND ah.IsCurrent = 1
            JOIN Apartments a ON a.Id = ah.ApartmentId
            JOIN Floors f ON f.Id = a.FloorId
            JOIN Buildings b ON b.Id = f.BuildingId
            WHERE r.Id = @residentId
            LIMIT 1;
            """;

        await using (var cmd = new MySqlCommand(residentSql, connection))
        {
            cmd.Parameters.AddWithValue("@residentId", residentId);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            if (await reader.ReadAsync(cancellationToken))
            {
                homeData.Resident = new ResidentHomeDto
                {
                    ResidentId = reader.GetString("ResidentId"),
                    FullName = reader.GetString("FullName"),
                    ApartmentNumber = reader.GetString("ApartmentNumber"),
                    FloorNumber = reader.GetString("FloorNumber"),
                    BuildingName = reader.GetString("BuildingName"),
                    BuildingCode = reader.GetString("BuildingCode"),
                    Area = reader.GetDecimal("Area"),
                    ContractType = reader.GetString("ContractType") == "Owner" ? "Chủ hộ (Owner)" : "Thuê (Tenant)",
                    StartDate = reader.GetString("StartDate"),
                    EndDate = reader.GetString("EndDate"),
                    Status = "Đang hiệu lực"
                };
            }
        }

        // 2. Latest Invoice Info
        const string invoiceSql = """
            SELECT
                i.InvoiceCode,
                i.BillingMonth,
                i.BillingYear,
                i.TotalAmount,
                i.PaidAmount,
                i.Status,
                p.PaymentMethod,
                DATE_FORMAT(p.PaymentDate, '%d/%m/%Y') AS PaymentDate
            FROM MonthlyInvoices i
            JOIN ApartmentHistories ah ON ah.ApartmentId = i.ApartmentId AND ah.IsCurrent = 1
            LEFT JOIN Payments p ON p.InvoiceId = i.Id AND p.Status = 'Success'
            WHERE ah.ResidentId = @residentId
            ORDER BY i.BillingYear DESC, i.BillingMonth DESC
            LIMIT 1;
            """;

        await using (var cmd = new MySqlCommand(invoiceSql, connection))
        {
            cmd.Parameters.AddWithValue("@residentId", residentId);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            if (await reader.ReadAsync(cancellationToken))
            {
                homeData.Invoice = new InvoiceHomeDto
                {
                    InvoiceCode = reader.GetString("InvoiceCode"),
                    BillingMonth = reader.GetInt32("BillingMonth"),
                    BillingYear = reader.GetInt32("BillingYear"),
                    TotalAmount = reader.GetDecimal("TotalAmount"),
                    PaidAmount = reader.GetDecimal("PaidAmount"),
                    Status = reader.GetString("Status"),
                    PaymentMethod = reader.IsDBNull(reader.GetOrdinal("PaymentMethod")) ? "VNPay QR" : reader.GetString("PaymentMethod"),
                    PaymentDate = reader.IsDBNull(reader.GetOrdinal("PaymentDate")) ? "02/09/2026" : reader.GetString("PaymentDate")
                };
            }
        }

        // 3. Vehicles Info
        const string vehiclesSql = """
            SELECT
                v.Id AS VehicleId,
                IFNULL(v.Brand, 'Phương tiện') AS Brand,
                v.VehicleType,
                v.LicensePlate,
                v.RfidCardCode,
                v.IsActive,
                ps.SlotCode,
                CONCAT('Hầm ', ps.BasementLevel) AS BasementLevel,
                CASE WHEN v.VehicleType = 'Car' THEN 1500000.00 ELSE 120000.00 END AS MonthlyPrice
            FROM Vehicles v
            LEFT JOIN ParkingSlots ps ON ps.VehicleId = v.Id
            WHERE v.ResidentId = @residentId AND v.IsActive = 1;
            """;

        await using (var cmd = new MySqlCommand(vehiclesSql, connection))
        {
            cmd.Parameters.AddWithValue("@residentId", residentId);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                homeData.Vehicles.Add(new VehicleHomeDto
                {
                    VehicleId = reader.GetString("VehicleId"),
                    Brand = reader.GetString("Brand"),
                    VehicleType = reader.GetString("VehicleType"),
                    LicensePlate = reader.GetString("LicensePlate"),
                    RfidCardCode = reader.GetString("RfidCardCode"),
                    IsActive = reader.GetBoolean("IsActive"),
                    SlotCode = reader.IsDBNull(reader.GetOrdinal("SlotCode")) ? "B1-B1-CAR-01" : reader.GetString("SlotCode"),
                    BasementLevel = reader.IsDBNull(reader.GetOrdinal("BasementLevel")) ? "Hầm B1" : reader.GetString("BasementLevel"),
                    MonthlyPrice = reader.GetDecimal("MonthlyPrice")
                });
            }
        }

        // 4. Upcoming Amenity Booking
        const string bookingSql = """
            SELECT
                ab.Id AS BookingId,
                am.Name AS AmenityName,
                am.Id AS AmenityId,
                DATE_FORMAT(ab.StartTime, '%d/%m/%Y') AS BookingDate,
                DATE_FORMAT(ab.StartTime, '%H:%i') AS StartTime,
                DATE_FORMAT(ab.EndTime, '%H:%i') AS EndTime,
                ab.NumberOfGuests,
                ab.Status
            FROM AmenityBookings ab
            JOIN Amenities am ON am.Id = ab.AmenityId
            WHERE ab.ResidentId = @residentId AND ab.Status = 'Confirmed'
            ORDER BY ab.StartTime DESC
            LIMIT 1;
            """;

        await using (var cmd = new MySqlCommand(bookingSql, connection))
        {
            cmd.Parameters.AddWithValue("@residentId", residentId);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            if (await reader.ReadAsync(cancellationToken))
            {
                homeData.UpcomingBooking = new AmenityBookingHomeDto
                {
                    BookingId = reader.GetString("BookingId"),
                    AmenityName = reader.GetString("AmenityName"),
                    AmenityId = reader.GetString("AmenityId"),
                    BookingDate = reader.GetString("BookingDate"),
                    StartTime = reader.GetString("StartTime"),
                    EndTime = reader.GetString("EndTime"),
                    NumberOfGuests = reader.GetInt32("NumberOfGuests"),
                    Status = reader.GetString("Status")
                };
            }
        }

        // 5. Latest Announcement
        const string announcementSql = """
            SELECT
                Title,
                Content
            FROM ComplaintRequests
            WHERE Status IN ('Pending', 'Processing', 'Assigned')
            ORDER BY CreatedAt DESC
            LIMIT 1;
            """;

        await using (var cmd = new MySqlCommand(announcementSql, connection))
        {
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            if (await reader.ReadAsync(cancellationToken))
            {
                homeData.Announcement = new AnnouncementHomeDto
                {
                    Title = reader.GetString("Title"),
                    Date = "Hôm nay",
                    Content = reader.GetString("Content"),
                    Hotline = "1900 8899"
                };
            }
            else
            {
                homeData.Announcement = new AnnouncementHomeDto
                {
                    Title = "Bảo trì thang máy Tháp Ruby",
                    Date = "Hôm nay",
                    Content = "Thang máy P1 & P2 tạm ngưng để kiểm định an toàn định kỳ từ 14:00 đến 17:00 ngày 10/09/2026. Quý cư dân vui lòng sử dụng thang hàng P3.",
                    Hotline = "1900 8899"
                };
            }
        }

        return homeData;
    }
}
