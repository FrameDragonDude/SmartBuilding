import '../entities/amenity_booking_detail.dart';
import '../repo/i_amenity_repository.dart';

class GetLatestBookingDetailUseCase {
  final IAmenityRepository repository;

  GetLatestBookingDetailUseCase(this.repository);

  Future<AmenityBookingDetail> execute({String residentId = 'Res1'}) async {
    return await repository.getLatestBookingDetail(residentId: residentId);
  }
}
