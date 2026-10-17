namespace SmartBuilding.Domain.Entities;

public sealed class Apartment
{
    public required string Id { get; init; }
    public required string ApartmentNumber { get; init; }
    public required string Status { get; init; }
}
