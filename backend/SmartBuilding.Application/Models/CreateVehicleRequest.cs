namespace SmartBuilding.Application.Models;

public sealed record CreateVehicleRequest(
    string ResidentId,
    string ApartmentId,
    string VehicleType,
    string LicensePlate,
    string RfidCardCode,
    string? Brand,
    string? SlotId);
