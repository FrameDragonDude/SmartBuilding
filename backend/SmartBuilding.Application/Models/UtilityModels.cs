namespace SmartBuilding.Application.Models;

public sealed record UtilityMeterDto(
    string Id,
    string ApartmentId,
    string ApartmentNumber,
    string BuildingId,
    string BuildingName,
    int FloorNumber,
    string MeterType,
    string MeterSerialNumber,
    DateTime InstallationDate,
    bool IsActive);

public sealed record UtilityUsageListItem(
    string Id,
    string MeterId,
    string ApartmentId,
    string ApartmentNumber,
    string BuildingId,
    string BuildingName,
    int FloorNumber,
    string MeterType,
    string MeterSerialNumber,
    int BillingMonth,
    int BillingYear,
    decimal PreviousReading,
    decimal CurrentReading,
    decimal Consumption,
    decimal CalculatedAmount,
    string? ProofImageUrl,
    DateTime? RecordedAt,
    bool IsRecorded,
    bool HasAnomaly,
    string? AnomalyReason);

public sealed record UtilitySummaryMetrics(
    int TotalMeters,
    int ElectricityMetersCount,
    int WaterMetersCount,
    int RecordedCount,
    int PendingCount,
    decimal TotalElectricityKwh,
    decimal TotalWaterM3,
    int AnomalyAlertsCount);

public sealed record RecordMeterReadingRequest(
    string MeterId,
    int BillingMonth,
    int BillingYear,
    decimal CurrentReading,
    string? ProofImageUrl);

public sealed record CreateMeterRequest(
    string ApartmentId,
    string MeterType,
    string MeterSerialNumber,
    DateTime? InstallationDate);

public sealed record BatchRecordReadingsRequest(
    List<RecordMeterReadingRequest> Readings);
