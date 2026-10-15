namespace SmartBuilding.Application.Models;

public sealed record ParkingSummaryMetrics(
    int TotalSlots,
    int OccupiedSlots,
    int AvailableSlots,
    int B1Total,
    int B1Occupied,
    int B2Total,
    int B2Occupied,
    int CarSlotsTotal,
    int CarSlotsOccupied,
    int MotoSlotsTotal,
    int MotoSlotsOccupied);
