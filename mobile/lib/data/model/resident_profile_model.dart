class ResidentProfileDataModel {
  final ResidentProfileInfoModel residentInfo;
  final ApartmentContractInfoModel? contractInfo;
  final List<ResidentDocumentModel> documents;
  final List<ResidentVehicleModel> vehicles;
  final AccountInfoModel? accountInfo;

  ResidentProfileDataModel({
    required this.residentInfo,
    this.contractInfo,
    this.documents = const [],
    this.vehicles = const [],
    this.accountInfo,
  });

  factory ResidentProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ResidentProfileDataModel(
      residentInfo: ResidentProfileInfoModel.fromJson(json['residentInfo'] ?? {}),
      contractInfo: json['contractInfo'] != null
          ? ApartmentContractInfoModel.fromJson(json['contractInfo'])
          : null,
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((d) => ResidentDocumentModel.fromJson(d))
              .toList()
          : [],
      vehicles: json['vehicles'] != null
          ? (json['vehicles'] as List)
              .map((v) => ResidentVehicleModel.fromJson(v))
              .toList()
          : [],
      accountInfo: json['accountInfo'] != null
          ? AccountInfoModel.fromJson(json['accountInfo'])
          : null,
    );
  }
}

class ResidentProfileInfoModel {
  final String id;
  final String fullName;
  final String identityCardNumber;
  final String phoneNumber;
  final String? email;
  final String dateOfBirth;
  final String gender;
  final String? avatarUrl;
  final String createdAt;

  ResidentProfileInfoModel({
    required this.id,
    required this.fullName,
    required this.identityCardNumber,
    required this.phoneNumber,
    this.email,
    required this.dateOfBirth,
    required this.gender,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ResidentProfileInfoModel.fromJson(Map<String, dynamic> json) {
    return ResidentProfileInfoModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      identityCardNumber: json['identityCardNumber'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? 'Nam',
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class ApartmentContractInfoModel {
  final String historyId;
  final String apartmentId;
  final String apartmentNumber;
  final String buildingName;
  final String floorDescription;
  final double area;
  final int roomsCount;
  final int bathroomsCount;
  final String contractType;
  final String startDate;
  final String? endDate;
  final String? contractFileUrl;
  final bool isCurrent;

  ApartmentContractInfoModel({
    required this.historyId,
    required this.apartmentId,
    required this.apartmentNumber,
    required this.buildingName,
    required this.floorDescription,
    required this.area,
    required this.roomsCount,
    required this.bathroomsCount,
    required this.contractType,
    required this.startDate,
    this.endDate,
    this.contractFileUrl,
    required this.isCurrent,
  });

  factory ApartmentContractInfoModel.fromJson(Map<String, dynamic> json) {
    return ApartmentContractInfoModel(
      historyId: json['historyId'] ?? '',
      apartmentId: json['apartmentId'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      buildingName: json['buildingName'] ?? '',
      floorDescription: json['floorDescription'] ?? '',
      area: (json['area'] ?? 0).toDouble(),
      roomsCount: json['roomsCount'] ?? 0,
      bathroomsCount: json['bathroomsCount'] ?? 0,
      contractType: json['contractType'] ?? 'Owner',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'],
      contractFileUrl: json['contractFileUrl'],
      isCurrent: json['isCurrent'] ?? true,
    );
  }
}

class ResidentDocumentModel {
  final String id;
  final String documentType;
  final String? documentNumber;
  final String? issuedDate;
  final String? issuedPlace;
  final String attachmentUrl;
  final String verificationStatus;

  ResidentDocumentModel({
    required this.id,
    required this.documentType,
    this.documentNumber,
    this.issuedDate,
    this.issuedPlace,
    required this.attachmentUrl,
    required this.verificationStatus,
  });

  factory ResidentDocumentModel.fromJson(Map<String, dynamic> json) {
    return ResidentDocumentModel(
      id: json['id'] ?? '',
      documentType: json['documentType'] ?? 'CCCD_Front',
      documentNumber: json['documentNumber'],
      issuedDate: json['issuedDate'],
      issuedPlace: json['issuedPlace'],
      attachmentUrl: json['attachmentUrl'] ?? '',
      verificationStatus: json['verificationStatus'] ?? 'Pending',
    );
  }
}

class ResidentVehicleModel {
  final String id;
  final String vehicleType;
  final String licensePlate;
  final String rfidCardCode;
  final String? brand;
  final String? registrationPaperUrl;
  final String? vehicleImageUrl;
  final bool isActive;
  final String? slotCode;
  final String? basementLevel;

  ResidentVehicleModel({
    required this.id,
    required this.vehicleType,
    required this.licensePlate,
    required this.rfidCardCode,
    this.brand,
    this.registrationPaperUrl,
    this.vehicleImageUrl,
    required this.isActive,
    this.slotCode,
    this.basementLevel,
  });

  factory ResidentVehicleModel.fromJson(Map<String, dynamic> json) {
    return ResidentVehicleModel(
      id: json['id'] ?? '',
      vehicleType: json['vehicleType'] ?? 'Car',
      licensePlate: json['licensePlate'] ?? '',
      rfidCardCode: json['rfidCardCode'] ?? '',
      brand: json['brand'],
      registrationPaperUrl: json['registrationPaperUrl'],
      vehicleImageUrl: json['vehicleImageUrl'],
      isActive: json['isActive'] ?? true,
      slotCode: json['slotCode'],
      basementLevel: json['basementLevel'],
    );
  }
}

class AccountInfoModel {
  final String accountId;
  final String username;
  final String email;
  final bool isActive;
  final String roleName;
  final String createdAt;

  AccountInfoModel({
    required this.accountId,
    required this.username,
    required this.email,
    required this.isActive,
    required this.roleName,
    required this.createdAt,
  });

  factory AccountInfoModel.fromJson(Map<String, dynamic> json) {
    return AccountInfoModel(
      accountId: json['accountId'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isActive: json['isActive'] ?? true,
      roleName: json['roleName'] ?? 'Cư dân chính thức',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
