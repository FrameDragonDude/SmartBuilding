namespace SmartBuilding.Domain.Entities;

public sealed class Resident
{
    public required string Id { get; init; }
    public required string FullName { get; init; }
    public required string PhoneNumber { get; init; }
    public string? Email { get; init; }
}
