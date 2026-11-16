import '../repo/i_amenity_repository.dart';

class BookAmenityUseCase {
  final IAmenityRepository repository;

  BookAmenityUseCase(this.repository);

  Future<String> execute({
    required String amenityId,
    required String residentId,
    required DateTime startTime,
    required DateTime endTime,
    int numberOfGuests = 1,
  }) {
    return repository.bookAmenity(
      amenityId: amenityId,
      residentId: residentId,
      startTime: startTime,
      endTime: endTime,
      numberOfGuests: numberOfGuests,
    );
  }
}
