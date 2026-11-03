class AmenityModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int maxCapacity;
  final String openTime;
  final String closeTime;
  final int slotDurationMinutes;
  final bool isActive;

  AmenityModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.maxCapacity,
    required this.openTime,
    required this.closeTime,
    required this.slotDurationMinutes,
    required this.isActive,
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
}

class AmenityBookingModel {
  final String id;
  final String amenityId;
  final String amenityName;
  final String? amenityImageUrl;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int numberOfGuests;
  final String status;

  AmenityBookingModel({
    required this.id,
    required this.amenityId,
    required this.amenityName,
    this.amenityImageUrl,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.numberOfGuests,
    required this.status,
  });

  factory AmenityBookingModel.fromJson(Map<String, dynamic> json) {
    return AmenityBookingModel(
      id: json['id'] ?? '',
      amenityId: json['amenityId'] ?? '',
      amenityName: json['amenityName'] ?? '',
      amenityImageUrl: json['amenityImageUrl'],
      bookingDate: json['bookingDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      numberOfGuests: json['numberOfGuests'] ?? 1,
      status: json['status'] ?? 'Confirmed',
    );
  }
}
