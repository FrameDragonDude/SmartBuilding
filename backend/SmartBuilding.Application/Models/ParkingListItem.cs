namespace SmartBuilding.Application.Models;

public sealed record ParkingListItem(
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
    string? FullName,
    string? PhoneNumber,
    string? ApartmentNumber);
