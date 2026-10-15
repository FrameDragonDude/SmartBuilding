using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface IResidentRepository
{
    Task<IReadOnlyList<BuildingOption>> GetBuildingsAsync(CancellationToken cancellationToken);

    Task<IReadOnlyList<ResidentListItem>> GetListAsync(
        string? search,
        string? status,
        string? contractType,
        string? buildingId,
        CancellationToken cancellationToken);

    Task<ResidentDetail?> GetDetailAsync(string apartmentId, CancellationToken cancellationToken);

    Task<ResidentSummaryMetrics> GetMetricsAsync(string? buildingId, CancellationToken cancellationToken);

    Task<IReadOnlyList<ApartmentOption>> GetApartmentsAsync(string? buildingId, CancellationToken cancellationToken);

    Task<string> CreateResidentAsync(CreateResidentRequest request, CancellationToken cancellationToken);
}
