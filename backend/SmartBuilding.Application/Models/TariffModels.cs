namespace SmartBuilding.Application.Models;

public sealed record TariffItem(
    string Id,
    string ServiceType,
    string TierName,
    decimal FromUnit,
    decimal? ToUnit,
    decimal UnitPrice,
    decimal VatRate,
    DateTime EffectiveDate);

public sealed record TariffRules(
    int MeterCutoffDay,
    int InvoiceIssueDay,
    int DueDay,
    int GracePeriodDays,
    decimal LateInterestRatePercent,
    int BlockRfidDays,
    bool AutoWaiveWithExtensionRequest);

public sealed record TariffAuditLog(
    string Period,
    string ItemName,
    string OldPrice,
    string NewPrice,
    string ChangePercent,
    string ApprovedBy);

public sealed record ForecastRevenueDto(
    decimal ManagementRevenue,
    decimal ParkingRevenue,
    decimal UtilityRevenue,
    decimal TotalMonthlyForecast);

public sealed record TariffConfigDto(
    IReadOnlyList<TariffItem> ManagementTariffs,
    IReadOnlyList<TariffItem> ElectricityTariffs,
    IReadOnlyList<TariffItem> WaterTariffs,
    IReadOnlyList<TariffItem> ParkingTariffs,
    TariffRules Rules,
    IReadOnlyList<TariffAuditLog> AuditLogs,
    ForecastRevenueDto Forecast);

public sealed record UpdateTariffPriceRequest(
    string TariffId,
    decimal NewUnitPrice);

public sealed record UpdateRulesRequest(
    int MeterCutoffDay,
    int InvoiceIssueDay,
    int DueDay,
    int GracePeriodDays,
    decimal LateInterestRatePercent,
    int BlockRfidDays,
    bool AutoWaiveWithExtensionRequest);
