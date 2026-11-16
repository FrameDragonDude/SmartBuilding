using Microsoft.Extensions.DependencyInjection;
using SmartBuilding.Application.Abstractions.Persistence;
using SmartBuilding.Infrastructure.Data;
using SmartBuilding.Infrastructure.Repositories;

namespace SmartBuilding.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, string connectionString = "")
    {
        if (!string.IsNullOrWhiteSpace(connectionString))
        {
            services.AddSingleton(new MySqlConnectionFactory(connectionString));
        }
        else
        {
            services.AddSingleton<MySqlConnectionFactory>();
        }

        services.AddScoped<IResidentRepository, ResidentRepository>();
        services.AddScoped<IParkingRepository, ParkingRepository>();
        services.AddScoped<IInvoiceRepository, InvoiceRepository>();
        services.AddScoped<ITariffRepository, TariffRepository>();
        services.AddScoped<IUtilityRepository, UtilityRepository>();
        services.AddScoped<IComplaintRepository, ComplaintRepository>();
        services.AddScoped<IHomeRepository, HomeRepository>();
        services.AddScoped<IAuthRepository, AuthRepository>();
        services.AddScoped<IAmenityRepository, AmenityRepository>();
        return services;
    }
}
