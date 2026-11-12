import '../repo/i_amenity_repository.dart';

class CancelBookingUseCase {
  final IAmenityRepository repository;

  CancelBookingUseCase(this.repository);

  Future<bool> execute(String bookingId) {
    return repository.cancelBooking(bookingId);
  }
}
