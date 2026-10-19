namespace SmartBuilding.Application.Models;

public class HomeDataDto
{
    public ResidentHomeDto? Resident { get; set; }
    public InvoiceHomeDto? Invoice { get; set; }
    public List<VehicleHomeDto> Vehicles { get; set; } = new();
    public AmenityBookingHomeDto? UpcomingBooking { get; set; }
    public AnnouncementHomeDto? Announcement { get; set; }
}

public class ResidentHomeDto
{
    public string ResidentId { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string ApartmentNumber { get; set; } = string.Empty;
    public string FloorNumber { get; set; } = string.Empty;
    public string BuildingName { get; set; } = string.Empty;
    public string BuildingCode { get; set; } = string.Empty;
    public decimal Area { get; set; }
    public string ContractType { get; set; } = string.Empty;
    public string StartDate { get; set; } = string.Empty;
    public string EndDate { get; set; } = string.Empty;
    public string Status { get; set; } = "Đang hiệu lực";
}

public class InvoiceHomeDto
{
    public string InvoiceCode { get; set; } = string.Empty;
    public int BillingMonth { get; set; }
    public int BillingYear { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? PaymentMethod { get; set; }
    public string? PaymentDate { get; set; }
}

public class VehicleHomeDto
{
    public string VehicleId { get; set; } = string.Empty;
    public string Brand { get; set; } = string.Empty;
    public string VehicleType { get; set; } = string.Empty;
    public string LicensePlate { get; set; } = string.Empty;
    public string RfidCardCode { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public string? SlotCode { get; set; }
    public string? BasementLevel { get; set; }
    public decimal MonthlyPrice { get; set; }
}

public class AmenityBookingHomeDto
{
    public string BookingId { get; set; } = string.Empty;
    public string AmenityName { get; set; } = string.Empty;
    public string AmenityId { get; set; } = string.Empty;
    public string BookingDate { get; set; } = string.Empty;
    public string StartTime { get; set; } = string.Empty;
    public string EndTime { get; set; } = string.Empty;
    public int NumberOfGuests { get; set; }
    public string Status { get; set; } = string.Empty;
}

public class AnnouncementHomeDto
{
    public string Title { get; set; } = string.Empty;
    public string Date { get; set; } = "Hôm nay";
    public string Content { get; set; } = string.Empty;
    public string Hotline { get; set; } = "1900 8899";
}
