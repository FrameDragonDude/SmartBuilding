import '../../common/mapper/amenity_mapper.dart';
import '../../domain/entities/amenity_booking_detail.dart';
import '../../domain/repo/i_amenity_repository.dart';
import '../datasources/amenity_remote_datasource.dart';
import '../model/amenity_model.dart';
import '../model/amenity_data_model.dart';

class AmenityRepository implements IAmenityRepository {
  final IAmenityRemoteDataSource remoteDataSource;

  AmenityRepository({IAmenityRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? AmenityRemoteDataSourceImpl();

  @override
  Future<List<AmenityModel>> getAmenities() {
    return remoteDataSource.getAmenities();
  }

  @override
  Future<List<AmenityBookingModel>> getMyBookings({String residentId = 'Res1'}) {
    return remoteDataSource.getMyBookings(residentId: residentId);
  }

  @override
  Future<AmenityBookingDetail> getBookingDetail(String bookingId) async {
    final model = await remoteDataSource.getBookingDetail(bookingId);
    return model.toEntity();
  }

  @override
  Future<AmenityBookingDetail> getLatestBookingDetail({String residentId = 'Res1'}) async {
    final model = await remoteDataSource.getLatestBookingDetail(residentId: residentId);
    return model.toEntity();
  }

  @override
  Future<String> bookAmenity({
    required String amenityId,
    required String residentId,
    required DateTime startTime,
    required DateTime endTime,
    int numberOfGuests = 1,
  }) {
    return remoteDataSource.bookAmenity(
      amenityId: amenityId,
      residentId: residentId,
      startTime: startTime,
      endTime: endTime,
      numberOfGuests: numberOfGuests,
    );
  }

  @override
  Future<bool> cancelBooking(String bookingId) {
    return remoteDataSource.cancelBooking(bookingId);
  }
}
