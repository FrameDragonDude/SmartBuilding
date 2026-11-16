using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface IComplaintRepository
{
    // Web Admin APIs (Long)
    Task<IReadOnlyList<ComplaintListItem>> GetListAsync(
        string? buildingId,
        string? category,
        string? status,
        string? search,
        CancellationToken cancellationToken);

    Task<ComplaintSummaryMetrics> GetMetricsAsync(
        string? buildingId,
        CancellationToken cancellationToken);

    Task<ComplaintListItem?> GetDetailAsync(
        string complaintId,
        CancellationToken cancellationToken);

    Task<string> CreateComplaintAsync(
        CreateComplaintRequest request,
        CancellationToken cancellationToken);

    Task<bool> AssignComplaintAsync(
        AssignComplaintRequest request,
        CancellationToken cancellationToken);

    Task<bool> ResolveComplaintAsync(
        ResolveComplaintRequest request,
        CancellationToken cancellationToken);

    Task<bool> UpdateStatusAsync(
        string complaintId,
        string status,
        CancellationToken cancellationToken);

    // Mobile App APIs (Phong)
    Task<ComplaintSummaryDataDto> GetComplaintsAsync(
        string? residentId,
        string? status,
        string? category,
        CancellationToken cancellationToken = default);

    Task<string> CreateComplaintAsync(
        CreateComplaintApiRequest request,
        CancellationToken cancellationToken = default);
}
