using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface ITariffRepository
{
    Task<TariffConfigDto> GetTariffConfigAsync(CancellationToken cancellationToken);

    Task<bool> UpdateTariffPriceAsync(UpdateTariffPriceRequest request, CancellationToken cancellationToken);

    Task<bool> UpdateRulesAsync(UpdateRulesRequest request, CancellationToken cancellationToken);

    Task<bool> ApproveDraftTariffAsync(CancellationToken cancellationToken);
}
