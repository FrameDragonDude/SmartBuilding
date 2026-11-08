namespace SmartBuilding.Domain.Entities;

public sealed class ComplaintRequest
{
    public required string Id { get; init; }
    public required string ResidentId { get; init; }
    public required string ApartmentId { get; init; }
    public required string Category { get; init; } // Sanitation, Noise, Security, FacilityDamage
    public required string Title { get; init; }
    public required string Content { get; init; }
    public string? AttachedImageUrl { get; init; }
    public string? ResolvedImageUrl { get; init; }
    public string Status { get; init; } = "Pending"; // Pending, Assigned, Processing, Resolved, Closed
    public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
    public DateTime? ResolvedAt { get; init; }
}
