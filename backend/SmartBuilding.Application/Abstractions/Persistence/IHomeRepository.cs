using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface IHomeRepository
{
    Task<HomeDataDto> GetHomeDataAsync(string? residentId, CancellationToken cancellationToken = default);
}
