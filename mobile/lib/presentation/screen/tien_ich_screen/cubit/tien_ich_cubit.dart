import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/amenity_repository.dart';
import 'tien_ich_state.dart';

class TienIchCubit extends Cubit<TienIchState> {
  final AmenityRepository amenityRepository;

  TienIchCubit({AmenityRepository? amenityRepository})
      : amenityRepository = amenityRepository ?? AmenityRepository(),
        super(TienIchInitial());

  Future<void> fetchAmenitiesData({String residentId = 'Res1'}) async {
    emit(TienIchLoading());
    try {
      final amenities = await amenityRepository.getAmenities();
      final myBookings = await amenityRepository.getMyBookings(residentId: residentId);
      emit(TienIchLoaded(amenities: amenities, myBookings: myBookings));
    } catch (e) {
      emit(TienIchError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void changeTab(int tabIndex) {
    if (state is TienIchLoaded) {
      final currentState = state as TienIchLoaded;
      emit(currentState.copyWith(activeTab: tabIndex));
    }
  }

  Future<void> bookAmenity({
    required String amenityId,
    required String residentId,
    required DateTime startTime,
    required DateTime endTime,
    int numberOfGuests = 1,
  }) async {
    try {
      final success = await amenityRepository.bookAmenity(
        amenityId: amenityId,
        residentId: residentId,
        startTime: startTime,
        endTime: endTime,
        numberOfGuests: numberOfGuests,
      );
      if (success) {
        emit(const BookingSuccessState("Đặt lịch tiện ích thành công!"));
        await fetchAmenitiesData(residentId: residentId);
      }
    } catch (e) {
      emit(TienIchError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> cancelBooking(String bookingId, {String residentId = 'Res1'}) async {
    try {
      final success = await amenityRepository.cancelBooking(bookingId);
      if (success) {
        emit(const BookingSuccessState("Hủy lịch đặt tiện ích thành công!"));
        await fetchAmenitiesData(residentId: residentId);
      }
    } catch (e) {
      emit(TienIchError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
