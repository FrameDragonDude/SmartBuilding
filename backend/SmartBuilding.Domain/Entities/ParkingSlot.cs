namespace SmartBuilding.Domain.Entities;

public sealed class ParkingSlot
{
    public required string Id { get; init; }
    public required string SlotCode { get; init; }
    public required string BasementLevel { get; init; }
    public required string SlotType { get; init; }
    public bool IsOccupied { get; init; }
}
