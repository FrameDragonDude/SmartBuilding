using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface IComplaintRepository
{
    Task<ComplaintSummaryDataDto> GetComplaintsAsync(
        string? residentId,
        string? status,
        string? category,
        CancellationToken cancellationToken = default);

    Task<string> CreateComplaintAsync(
        CreateComplaintApiRequest request,
        CancellationToken cancellationToken = default);
}
