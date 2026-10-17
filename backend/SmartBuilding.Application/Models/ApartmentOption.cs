namespace SmartBuilding.Application.Models;

public sealed record ApartmentOption(
    string Id,
    string ApartmentNumber,
    string Status,
    decimal Area,
    int FloorNumber,
    string BuildingName);
