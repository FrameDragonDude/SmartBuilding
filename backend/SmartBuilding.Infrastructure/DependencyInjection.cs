using Microsoft.Extensions.DependencyInjection;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Infrastructure.Data;
using SmartBuilding.Infrastructure.Repositories;

namespace SmartBuilding.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, string connectionString)
    {
        services.AddSingleton(new MySqlConnectionFactory(connectionString));
        services.AddScoped<IResidentRepository, ResidentRepository>();
        services.AddScoped<IParkingRepository, ParkingRepository>();
        services.AddScoped<IInvoiceRepository, InvoiceRepository>();
        services.AddScoped<ITariffRepository, TariffRepository>();
        return services;
    }
}
