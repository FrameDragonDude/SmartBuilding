using MySqlConnector;

var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("SmartBuilding") ?? throw new InvalidOperationException("Missing SmartBuilding connection string.");
builder.Services.AddOpenApi();
builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy.WithOrigins("http://127.0.0.1:5173", "http://localhost:5173").AllowAnyHeader().AllowAnyMethod()));
builder.Services.AddScoped(_ => new MySqlConnection(connectionString));
var app = builder.Build();
app.UseCors();
if (app.Environment.IsDevelopment()) app.MapOpenApi();

app.MapGet("/api/residents", async (string? search, MySqlConnection connection, CancellationToken token) =>
{
    const string sql = """
        SELECT a.Id ApartmentId, a.ApartmentNumber, a.Status ApartmentStatus, r.Id ResidentId, r.FullName, r.PhoneNumber, r.Email, ah.ContractType, ah.StartDate
        FROM Apartments a LEFT JOIN ApartmentHistories ah ON ah.ApartmentId = a.Id AND ah.IsCurrent = 1
        LEFT JOIN Residents r ON r.Id = ah.ResidentId
        WHERE (@search IS NULL OR @search = '' OR a.ApartmentNumber LIKE CONCAT('%', @search, '%') OR r.FullName LIKE CONCAT('%', @search, '%') OR r.PhoneNumber LIKE CONCAT('%', @search, '%'))
        ORDER BY a.ApartmentNumber LIMIT 100;
        """;
    await connection.OpenAsync(token); await using var command = new MySqlCommand(sql, connection); command.Parameters.AddWithValue("@search", search);
    await using var reader = await command.ExecuteReaderAsync(token); var results = new List<object>();
    while (await reader.ReadAsync(token)) results.Add(new { apartmentId = reader.GetString("ApartmentId"), apartmentNumber = reader.GetString("ApartmentNumber"), apartmentStatus = reader.GetString("ApartmentStatus"), residentId = reader.IsDBNull(reader.GetOrdinal("ResidentId")) ? null : reader.GetString("ResidentId"), fullName = reader.IsDBNull(reader.GetOrdinal("FullName")) ? null : reader.GetString("FullName"), phoneNumber = reader.IsDBNull(reader.GetOrdinal("PhoneNumber")) ? null : reader.GetString("PhoneNumber"), email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString("Email"), contractType = reader.IsDBNull(reader.GetOrdinal("ContractType")) ? null : reader.GetString("ContractType") });
    return Results.Ok(results);
});

app.MapGet("/api/parking", async (string? search, MySqlConnection connection, CancellationToken token) =>
{
    const string sql = """
        SELECT ps.Id SlotId, ps.SlotCode, ps.BasementLevel, ps.SlotType, ps.IsOccupied, v.Id VehicleId, v.VehicleType, v.LicensePlate, v.RfidCardCode, v.Brand, r.FullName, r.PhoneNumber, a.ApartmentNumber
        FROM ParkingSlots ps LEFT JOIN Vehicles v ON v.Id = ps.VehicleId LEFT JOIN Residents r ON r.Id = v.ResidentId LEFT JOIN Apartments a ON a.Id = v.ApartmentId
        WHERE (@search IS NULL OR @search = '' OR ps.SlotCode LIKE CONCAT('%', @search, '%') OR v.LicensePlate LIKE CONCAT('%', @search, '%') OR v.RfidCardCode LIKE CONCAT('%', @search, '%') OR r.FullName LIKE CONCAT('%', @search, '%'))
        ORDER BY ps.BasementLevel, ps.SlotCode LIMIT 100;
        """;
    await connection.OpenAsync(token); await using var command = new MySqlCommand(sql, connection); command.Parameters.AddWithValue("@search", search);
    await using var reader = await command.ExecuteReaderAsync(token); var results = new List<object>();
    while (await reader.ReadAsync(token)) results.Add(new { slotId = reader.GetString("SlotId"), slotCode = reader.GetString("SlotCode"), basementLevel = reader.GetString("BasementLevel"), slotType = reader.GetString("SlotType"), isOccupied = reader.GetBoolean("IsOccupied"), vehicleId = reader.IsDBNull(reader.GetOrdinal("VehicleId")) ? null : reader.GetString("VehicleId"), vehicleType = reader.IsDBNull(reader.GetOrdinal("VehicleType")) ? null : reader.GetString("VehicleType"), licensePlate = reader.IsDBNull(reader.GetOrdinal("LicensePlate")) ? null : reader.GetString("LicensePlate"), rfidCardCode = reader.IsDBNull(reader.GetOrdinal("RfidCardCode")) ? null : reader.GetString("RfidCardCode"), brand = reader.IsDBNull(reader.GetOrdinal("Brand")) ? null : reader.GetString("Brand"), fullName = reader.IsDBNull(reader.GetOrdinal("FullName")) ? null : reader.GetString("FullName"), phoneNumber = reader.IsDBNull(reader.GetOrdinal("PhoneNumber")) ? null : reader.GetString("PhoneNumber"), apartmentNumber = reader.IsDBNull(reader.GetOrdinal("ApartmentNumber")) ? null : reader.GetString("ApartmentNumber") });
    return Results.Ok(results);
});

app.MapGet("/api/health", () => Results.Ok(new { status = "ok" }));
app.Run();
