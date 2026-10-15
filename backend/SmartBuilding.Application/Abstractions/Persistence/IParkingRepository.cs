using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface IParkingRepository
{
    Task<IReadOnlyList<ParkingListItem>> GetListAsync(
        string? search,
        string? basement,
        string? slotType,
        bool? isOccupied,
        string? buildingId,
        CancellationToken cancellationToken);

    Task<ParkingSummaryMetrics> GetMetricsAsync(string? buildingId, CancellationToken cancellationToken);

    Task<ParkingDetailDto?> GetDetailAsync(string slotId, CancellationToken cancellationToken);

    Task<string> RegisterVehicleAsync(CreateVehicleRequest request, CancellationToken cancellationToken);

    Task<bool> ReleaseSlotAsync(string slotId, CancellationToken cancellationToken);
}
