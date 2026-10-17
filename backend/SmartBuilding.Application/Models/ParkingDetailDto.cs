namespace SmartBuilding.Application.Models;

public sealed record ParkingDetailDto(
    string SlotId,
    string SlotCode,
    string BasementLevel,
    string SlotType,
    bool IsOccupied,
    string? VehicleId,
    string? VehicleType,
    string? LicensePlate,
    string? RfidCardCode,
    string? Brand,
    bool? IsActive,
    DateTime? RegisteredAt,
    string? ResidentId,
    string? FullName,
    string? PhoneNumber,
    string? IdentityCardNumber,
    string? ApartmentId,
    string? ApartmentNumber,
    string? BuildingName);
