import '../../data/model/amenity_model.dart';
import '../../data/model/amenity_data_model.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/entities/amenity_booking_detail.dart';

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

extension AmenityBookingDetailMapper on AmenityBookingDetailModel {
  AmenityBookingDetail toEntity() {
    return AmenityBookingDetail(
      id: id,
      bookingCode: bookingCode,
      amenityId: amenityId,
      blockName: blockName,
      amenityTitle: amenityTitle,
      locationText: locationText,
      timeRange: timeRange,
      bookingDate: bookingDate,
      apartmentNumber: apartmentNumber,
      residentName: residentName,
      numberOfGuests: numberOfGuests,
      maxCapacity: maxCapacity,
      idCardNumber: idCardNumber,
      feeText: feeText,
      status: status,
      statusText: statusText,
      ticketCodeText: ticketCodeText,
      qrData: qrData,
      amenityImageUrl: amenityImageUrl,
    );
  }
}
