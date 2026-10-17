namespace SmartBuilding.Domain.Entities;

public sealed class Vehicle
{
    public required string Id { get; init; }
    public required string LicensePlate { get; init; }
    public required string RfidCardCode { get; init; }
    public required string VehicleType { get; init; }
}
