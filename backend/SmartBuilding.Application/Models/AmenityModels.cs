namespace SmartBuilding.Application.Models;

public class AmenityDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public int MaxCapacity { get; set; }
    public string OpenTime { get; set; } = string.Empty;
    public string CloseTime { get; set; } = string.Empty;
    public int SlotDurationMinutes { get; set; }
    public bool IsActive { get; set; }
}

public class AmenityBookingDto
{
    public string Id { get; set; } = string.Empty;
    public string AmenityId { get; set; } = string.Empty;
    public string AmenityName { get; set; } = string.Empty;
    public string? AmenityImageUrl { get; set; }
    public string BookingDate { get; set; } = string.Empty;
    public string StartTime { get; set; } = string.Empty;
    public string EndTime { get; set; } = string.Empty;
    public int NumberOfGuests { get; set; }
    public string Status { get; set; } = "Confirmed";
    public string CreatedAt { get; set; } = string.Empty;
}

public class AmenityBookingDetailDto
{
    public string Id { get; set; } = string.Empty;
    public string BookingCode { get; set; } = "#AB1";
    public string AmenityId { get; set; } = string.Empty;
    public string BlockName { get; set; } = "KHỐI RUBY SUITES";
    public string AmenityTitle { get; set; } = "Vườn Nướng BBQ Tầng Thượng";
    public string LocationText { get; set; } = "Bếp nướng BBQ-03 • Tầng 38 Tháp Ruby";
    public string TimeRange { get; set; } = "18:00 - 20:00";
    public string BookingDate { get; set; } = "Hôm nay, 12/09/2026";
    public string ApartmentNumber { get; set; } = "Căn RB-0101";
    public string ResidentName { get; set; } = "Nguyễn Văn An";
    public int NumberOfGuests { get; set; } = 10;
    public int MaxCapacity { get; set; } = 20;
    public string IdCardNumber { get; set; } = "079095001234";
    public string FeeText { get; set; } = "Miễn phí cư dân (Ruby Privilege)";
    public string Status { get; set; } = "Confirmed";
    public string StatusText { get; set; } = "ĐÃ XÁC NHẬN";
    public string TicketCodeText { get; set; } = "QR - AB1 - 20260912 - RB0101";
    public string QrData { get; set; } = "QR-AB1-20260912-RB0101";
    public string? AmenityImageUrl { get; set; }
}

public class CreateAmenityBookingRequest
{
    public string AmenityId { get; set; } = string.Empty;
    public string ResidentId { get; set; } = string.Empty;
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public int NumberOfGuests { get; set; } = 1;
}
