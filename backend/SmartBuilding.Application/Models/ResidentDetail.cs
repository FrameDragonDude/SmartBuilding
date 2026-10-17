namespace SmartBuilding.Application.Models;

public sealed record VehicleDto(
    string Id,
    string VehicleType,
    string LicensePlate,
    string RfidCardCode,
    string? Brand);

public sealed record DocumentDto(
    string Id,
    string DocumentType,
    string? DocumentNumber,
    DateTime? IssuedDate,
    string? IssuedPlace,
    string AttachmentUrl,
    string VerificationStatus);

public sealed record InvoiceDto(
    string Id,
    string InvoiceCode,
    int BillingMonth,
    int BillingYear,
    decimal TotalAmount,
    decimal PaidAmount,
    string Status,
    DateTime DueDate);

public sealed record ResidentDetail(
    string? ResidentId,
    string? FullName,
    string? IdentityCardNumber,
    string? PhoneNumber,
    string? Email,
    DateTime? DateOfBirth,
    string? Gender,
    string? AvatarUrl,
    DateTime? ResidentCreatedAt,
    string ApartmentId,
    string ApartmentNumber,
    decimal Area,
    int RoomsCount,
    int BathroomsCount,
    string ApartmentStatus,
    string? FloorDescription,
    string? BuildingName,
    string? ContractType,
    DateTime? ContractStartDate,
    DateTime? ContractEndDate,
    IReadOnlyList<VehicleDto> Vehicles,
    IReadOnlyList<DocumentDto> Documents,
    IReadOnlyList<InvoiceDto> Invoices);
