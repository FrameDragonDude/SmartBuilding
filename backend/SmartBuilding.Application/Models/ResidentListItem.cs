namespace SmartBuilding.Application.Models;

public sealed record ResidentListItem(
    string ApartmentId,
    string ApartmentNumber,
    string ApartmentStatus,
    string? ResidentId,
    string? FullName,
    string? PhoneNumber,
    string? Email,
    string? ContractType);
