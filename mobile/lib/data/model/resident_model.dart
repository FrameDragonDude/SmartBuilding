import '../../domain/entities/resident.dart';

class ResidentModel extends Resident {
  ResidentModel({
    required super.id,
    required super.fullName,
    required super.identityCardNumber,
    required super.phoneNumber,
    super.email,
    required super.dateOfBirth,
    required super.gender,
    super.avatarUrl,
  });

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      identityCardNumber: json['identityCardNumber'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? 'Nam',
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'identityCardNumber': identityCardNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'avatarUrl': avatarUrl,
    };
  }
}
