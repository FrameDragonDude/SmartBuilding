namespace SmartBuilding.Domain.Entities;

public sealed class UtilityMeter
{
    public required string Id { get; init; }
    public required string ApartmentId { get; init; }
    public required string MeterType { get; init; } // Electricity, Water
    public required string MeterSerialNumber { get; init; }
    public required DateTime InstallationDate { get; init; }
    public bool IsActive { get; init; } = true;
}
