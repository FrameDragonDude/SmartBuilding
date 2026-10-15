import '../../data/model/resident_model.dart';
import '../../domain/entities/resident.dart';

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
