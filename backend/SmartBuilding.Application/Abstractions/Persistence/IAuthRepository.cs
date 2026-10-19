using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface IAuthRepository
{
    Task<AuthResponse?> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
    Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default);
}
