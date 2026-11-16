namespace SmartBuilding.Application.Models;

// Web Admin Models (Long)
public sealed record ComplaintListItem(
    string Id,
    string ResidentId,
    string ResidentName,
    string PhoneNumber,
    string ApartmentId,
    string ApartmentNumber,
    string BuildingId,
    string BuildingName,
    string Category,
    string Title,
    string Content,
    string? AttachedImageUrl,
    string? ResolvedImageUrl,
    string Status,
    DateTime CreatedAt,
    DateTime? ResolvedAt);

public sealed record ComplaintSummaryMetrics(
    int TotalComplaints,
    int PendingCount,
    int AssignedCount,
    int ProcessingCount,
    int ResolvedCount,
    int ClosedCount);

public sealed record CreateComplaintRequest(
    string ResidentId,
    string ApartmentId,
    string Category,
    string Title,
    string Content,
    string? AttachedImageUrl);

public sealed record AssignComplaintRequest(
    string ComplaintId,
    string AssignedToRoleOrName,
    string? Note);

public sealed record ResolveComplaintRequest(
    string ComplaintId,
    string ResolvedImageUrl,
    string? ResolutionNote);

public sealed record UpdateComplaintStatusRequest(
    string ComplaintId,
    string Status);

// Mobile App Models (Phong)
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
