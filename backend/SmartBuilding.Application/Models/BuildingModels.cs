namespace SmartBuilding.Application.Models;

public sealed record BuildingOption(
    string Id,
    string BuildingCode,
    string Name,
    int TotalFloors,
    int TotalBasements,
    string Address,
    int TotalApartments);
