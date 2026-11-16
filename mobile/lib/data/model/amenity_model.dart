import '../../domain/entities/amenity.dart';

class AmenityModel extends Amenity {
  final bool isActive;

  AmenityModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.maxCapacity,
    required super.openTime,
    required super.closeTime,
    required super.slotDurationMinutes,
    this.isActive = true,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      maxCapacity: json['maxCapacity'] ?? 1,
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      slotDurationMinutes: json['slotDurationMinutes'] ?? 60,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'maxCapacity': maxCapacity,
      'openTime': openTime,
      'closeTime': closeTime,
      'slotDurationMinutes': slotDurationMinutes,
      'isActive': isActive,
    };
  }
}
