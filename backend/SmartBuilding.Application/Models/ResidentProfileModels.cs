namespace SmartBuilding.Application.Models;

public class ResidentProfileDataDto
{
    public ResidentProfileInfoDto ResidentInfo { get; set; } = new();
    public ApartmentContractInfoDto? ContractInfo { get; set; }
    public List<ResidentDocumentDto> Documents { get; set; } = new();
    public List<ResidentVehicleDto> Vehicles { get; set; } = new();
    public AccountInfoDto? AccountInfo { get; set; }
}

public class ResidentProfileInfoDto
{
    public string Id { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string IdentityCardNumber { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string DateOfBirth { get; set; } = string.Empty;
    public string Gender { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public string CreatedAt { get; set; } = string.Empty;
}

public class ApartmentContractInfoDto
{
    public string HistoryId { get; set; } = string.Empty;
    public string ApartmentId { get; set; } = string.Empty;
    public string ApartmentNumber { get; set; } = string.Empty;
    public string BuildingName { get; set; } = string.Empty;
    public string FloorDescription { get; set; } = string.Empty;
    public decimal Area { get; set; }
    public int RoomsCount { get; set; }
    public int BathroomsCount { get; set; }
    public string ContractType { get; set; } = string.Empty;
    public string StartDate { get; set; } = string.Empty;
    public string? EndDate { get; set; }
    public string? ContractFileUrl { get; set; }
    public bool IsCurrent { get; set; }
}

public class ResidentDocumentDto
{
    public string Id { get; set; } = string.Empty;
    public string DocumentType { get; set; } = string.Empty;
    public string? DocumentNumber { get; set; }
    public string? IssuedDate { get; set; }
    public string? IssuedPlace { get; set; }
    public string AttachmentUrl { get; set; } = string.Empty;
    public string VerificationStatus { get; set; } = "Pending";
}

public class ResidentVehicleDto
{
    public string Id { get; set; } = string.Empty;
    public string VehicleType { get; set; } = string.Empty;
    public string LicensePlate { get; set; } = string.Empty;
    public string RfidCardCode { get; set; } = string.Empty;
    public string? Brand { get; set; }
    public string? RegistrationPaperUrl { get; set; }
    public string? VehicleImageUrl { get; set; }
    public bool IsActive { get; set; }
    public string? SlotCode { get; set; }
    public string? BasementLevel { get; set; }
}

public class AccountInfoDto
{
    public string AccountId { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public string RoleName { get; set; } = "Cư dân chính thức";
    public string CreatedAt { get; set; } = string.Empty;
}
