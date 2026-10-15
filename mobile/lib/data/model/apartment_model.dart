import '../../domain/entities/apartment.dart';

class ApartmentModel extends Apartment {
  ApartmentModel({
    required super.id,
    required super.floorId,
    required super.apartmentNumber,
    required super.area,
    required super.roomsCount,
    required super.bathroomsCount,
    required super.status,
  });

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    return ApartmentModel(
      id: json['id'] ?? '',
      floorId: json['floorId'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      area: (json['area'] ?? 0).toDouble(),
      roomsCount: json['roomsCount'] ?? 0,
      bathroomsCount: json['bathroomsCount'] ?? 0,
      status: json['status'] ?? 'Available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floorId': floorId,
      'apartmentNumber': apartmentNumber,
      'area': area,
      'roomsCount': roomsCount,
      'bathroomsCount': bathroomsCount,
      'status': status,
    };
  }
}
