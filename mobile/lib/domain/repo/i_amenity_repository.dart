import '../../data/model/amenity_model.dart';
import '../../data/model/amenity_data_model.dart';
import '../entities/amenity_booking_detail.dart';

abstract class IAmenityRepository {
  Future<List<AmenityModel>> getAmenities();
  Future<List<AmenityBookingModel>> getMyBookings({String residentId });
  Future<AmenityBookingDetail> getBookingDetail(String bookingId);
  Future<AmenityBookingDetail> getLatestBookingDetail({String residentId });
  Future<String> bookAmenity({
    required String amenityId,
    required String residentId,
    required DateTime startTime,
    required DateTime endTime,
    int numberOfGuests = 1,
  });
  Future<bool> cancelBooking(String bookingId);
}
