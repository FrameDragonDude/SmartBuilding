import '../../data/model/apartment_model.dart';
import '../../domain/entities/apartment.dart';

extension ApartmentMapper on ApartmentModel {
  Apartment toEntity() {
    return Apartment(
      id: id,
      floorId: floorId,
      apartmentNumber: apartmentNumber,
      area: area,
      roomsCount: roomsCount,
      bathroomsCount: bathroomsCount,
      status: status,
    );
  }
}
