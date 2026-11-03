using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface IAmenityRepository
{
    Task<IReadOnlyList<AmenityDto>> GetAmenitiesAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AmenityBookingDto>> GetMyBookingsAsync(string residentId, CancellationToken cancellationToken = default);
    Task<string> CreateBookingAsync(CreateAmenityBookingRequest request, CancellationToken cancellationToken = default);
    Task<bool> CancelBookingAsync(string bookingId, CancellationToken cancellationToken = default);
}
