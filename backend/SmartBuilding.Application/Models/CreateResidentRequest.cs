namespace SmartBuilding.Application.Models;

public sealed record CreateResidentRequest(
    string FullName,
    string IdentityCardNumber,
    string PhoneNumber,
    string? Email,
    DateTime DateOfBirth,
    string Gender,
    string ApartmentId,
    string ContractType,
    DateTime StartDate);
