namespace SmartBuilding.Domain.Entities;

public sealed class UtilityUsage
{
    public required string Id { get; init; }
    public required string MeterId { get; init; }
    public required int BillingMonth { get; init; }
    public required int BillingYear { get; init; }
    public required decimal PreviousReading { get; init; }
    public required decimal CurrentReading { get; init; }
    public decimal Consumption => CurrentReading - PreviousReading;
    public decimal CalculatedAmount { get; init; }
    public string? ProofImageUrl { get; init; }
    public DateTime RecordedAt { get; init; } = DateTime.UtcNow;
}
