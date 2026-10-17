using MySqlConnector;

namespace SmartBuilding.Infrastructure.Data;

public sealed class MySqlConnectionFactory(string connectionString)
{
    public MySqlConnection CreateConnection() => new(connectionString);
}
