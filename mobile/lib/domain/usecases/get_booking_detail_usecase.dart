import '../entities/amenity_booking_detail.dart';
import '../repo/i_amenity_repository.dart';

class GetBookingDetailUseCase {
  final IAmenityRepository repository;

  GetBookingDetailUseCase(this.repository);

  Future<AmenityBookingDetail> execute(String bookingId) async {
    return await repository.getBookingDetail(bookingId);
  }
}
