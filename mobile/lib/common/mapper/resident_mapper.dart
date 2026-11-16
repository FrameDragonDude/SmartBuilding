import '../../data/model/resident_model.dart';
import '../../data/model/resident_profile_model.dart';
import '../../domain/entities/resident.dart';
import '../../domain/entities/resident_profile_entity.dart';

extension ResidentMapper on ResidentModel {
  Resident toEntity() {
    return Resident(
      id: id,
      fullName: fullName,
      identityCardNumber: identityCardNumber,
      phoneNumber: phoneNumber,
      email: email,
      dateOfBirth: dateOfBirth,
      gender: gender,
      avatarUrl: avatarUrl,
    );
  }
}

extension ResidentProfileMapper on ResidentProfileDataModel {
  ResidentProfileEntity toEntity() {
    return ResidentProfileEntity(
      residentInfo: ResidentProfileInfoEntity(
        id: residentInfo.id,
        fullName: residentInfo.fullName,
        identityCardNumber: residentInfo.identityCardNumber,
        phoneNumber: residentInfo.phoneNumber,
        email: residentInfo.email,
        gender: residentInfo.gender,
        avatarUrl: residentInfo.avatarUrl,
      ),
      contractInfo: contractInfo != null
          ? ApartmentContractInfoEntity(
              apartmentNumber: contractInfo!.apartmentNumber,
              buildingName: contractInfo!.buildingName,
              contractType: contractInfo!.contractType,
              startDate: contractInfo!.startDate,
              isCurrent: contractInfo!.isCurrent,
            )
          : null,
      vehicles: vehicles
          .map((v) => ResidentVehicleEntity(
                id: v.id,
                vehicleType: v.vehicleType,
                licensePlate: v.licensePlate,
                brand: v.brand,
                isActive: v.isActive,
                slotCode: v.slotCode,
              ))
          .toList(),
    );
  }
}
