namespace SmartBuilding.Application.Models;

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
