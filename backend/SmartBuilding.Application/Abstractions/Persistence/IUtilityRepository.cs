using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface IUtilityRepository
{
    Task<IReadOnlyList<UtilityMeterDto>> GetMeterListAsync(
        string? buildingId,
        string? meterType,
        string? search,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<UtilityUsageListItem>> GetUsageListAsync(
        string? buildingId,
        int? floorNumber,
        string? meterType,
        int month,
        int year,
        string? search,
        CancellationToken cancellationToken);

    Task<UtilitySummaryMetrics> GetSummaryMetricsAsync(
        string? buildingId,
        int month,
        int year,
        CancellationToken cancellationToken);

    Task<string> RecordReadingAsync(
        RecordMeterReadingRequest request,
        CancellationToken cancellationToken);

    Task<string> RegisterMeterAsync(
        CreateMeterRequest request,
        CancellationToken cancellationToken);

    Task<bool> LockBillingCycleAsync(
        string buildingId,
        int month,
        int year,
        CancellationToken cancellationToken);
}
