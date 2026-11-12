class ResidentProfileEntity {
  final ResidentProfileInfoEntity residentInfo;
  final ApartmentContractInfoEntity? contractInfo;
  final List<ResidentVehicleEntity> vehicles;

  const ResidentProfileEntity({
    required this.residentInfo,
    this.contractInfo,
    this.vehicles = const [],
  });
}

class ResidentProfileInfoEntity {
  final String id;
  final String fullName;
  final String identityCardNumber;
  final String phoneNumber;
  final String? email;
  final String gender;
  final String? avatarUrl;

  const ResidentProfileInfoEntity({
    required this.id,
    required this.fullName,
    required this.identityCardNumber,
    required this.phoneNumber,
    this.email,
    required this.gender,
    this.avatarUrl,
  });
}

class ApartmentContractInfoEntity {
  final String apartmentNumber;
  final String buildingName;
  final String contractType;
  final String startDate;
  final bool isCurrent;

  const ApartmentContractInfoEntity({
    required this.apartmentNumber,
    required this.buildingName,
    required this.contractType,
    required this.startDate,
    required this.isCurrent,
  });
}

class ResidentVehicleEntity {
  final String id;
  final String vehicleType;
  final String licensePlate;
  final String? brand;
  final bool isActive;
  final String? slotCode;

  const ResidentVehicleEntity({
    required this.id,
    required this.vehicleType,
    required this.licensePlate,
    this.brand,
    required this.isActive,
    this.slotCode,
  });
}
