namespace SmartBuilding.Application.Models;

public sealed record ResidentSummaryMetrics(
    int TotalApartments,
    int OccupiedApartments,
    int AvailableApartments,
    int TotalResidents,
    int PendingApprovals);
