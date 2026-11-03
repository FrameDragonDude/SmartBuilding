namespace SmartBuilding.Application.Models;

public class ComplaintSummaryDataDto
{
    public int TotalCount { get; set; }
    public int PendingCount { get; set; }
    public int ProcessingCount { get; set; }
    public int ResolvedCount { get; set; }
    public List<ComplaintListItemDto> Complaints { get; set; } = new();
}

public class ComplaintListItemDto
{
    public string Id { get; set; } = string.Empty;
    public string ApartmentNumber { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string? AttachedImageUrl { get; set; }
    public string? ResolvedImageUrl { get; set; }
    public string Status { get; set; } = "Pending";
    public string CreatedAt { get; set; } = string.Empty;
    public string? ResolvedAt { get; set; }
}

public class CreateComplaintApiRequest
{
    public string ResidentId { get; set; } = string.Empty;
    public string ApartmentId { get; set; } = string.Empty;
    public string Category { get; set; } = "Sanitation";
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string? AttachedImageUrl { get; set; }
}
