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

public class CreateAmenityBookingRequest
{
    public string AmenityId { get; set; } = string.Empty;
    public string ResidentId { get; set; } = string.Empty;
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public int NumberOfGuests { get; set; } = 1;
}
