import '../../data/model/amenity_model.dart';
import '../../domain/entities/amenity.dart';

extension AmenityMapper on AmenityModel {
  Amenity toEntity() {
    return Amenity(
      id: id,
      name: name,
      imageUrl: imageUrl,
      maxCapacity: maxCapacity,
      openTime: openTime,
      closeTime: closeTime,
      slotDurationMinutes: slotDurationMinutes,
    );
  }
}
