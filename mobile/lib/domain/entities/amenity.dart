class Amenity {
  final String id;
  final String name;
  final String? imageUrl;
  final int maxCapacity;
  final String openTime;
  final String closeTime;
  final int slotDurationMinutes;

  Amenity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.maxCapacity,
    required this.openTime,
    required this.closeTime,
    required this.slotDurationMinutes,
  });
}
