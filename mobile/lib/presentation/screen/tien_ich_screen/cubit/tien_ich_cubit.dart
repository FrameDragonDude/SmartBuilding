import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/amenity_repository.dart';
import '../../../../domain/usecases/book_amenity_usecase.dart';
import '../../../../domain/usecases/cancel_booking_usecase.dart';
import '../../../../domain/usecases/get_amenities_usecase.dart';
import 'tien_ich_state.dart';

class TienIchCubit extends Cubit<TienIchState> {
  final GetAmenitiesUseCase getAmenitiesUseCase;
  final BookAmenityUseCase bookAmenityUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final AmenityRepository amenityRepository;

  TienIchCubit({
    GetAmenitiesUseCase? getAmenitiesUseCase,
    BookAmenityUseCase? bookAmenityUseCase,
    CancelBookingUseCase? cancelBookingUseCase,
    AmenityRepository? amenityRepository,
  })  : getAmenitiesUseCase = getAmenitiesUseCase ?? GetAmenitiesUseCase(AmenityRepository()),
        bookAmenityUseCase = bookAmenityUseCase ?? BookAmenityUseCase(AmenityRepository()),
        cancelBookingUseCase = cancelBookingUseCase ?? CancelBookingUseCase(AmenityRepository()),
        amenityRepository = amenityRepository ?? AmenityRepository(),
        super(TienIchInitial());

  Future<void> fetchAmenitiesData({String residentId = 'Res1', int targetTab = 0}) async {
    final currentTab = state is TienIchLoaded ? (state as TienIchLoaded).activeTab : targetTab;
    emit(TienIchLoading());
    try {
      final amenities = await getAmenitiesUseCase.execute();
      final myBookings = await amenityRepository.getMyBookings(residentId: residentId);
      emit(TienIchLoaded(amenities: amenities, myBookings: myBookings, activeTab: currentTab));
    } catch (e) {
      emit(TienIchError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void changeTab(int tabIndex, {String residentId = 'Res1'}) {
    if (state is TienIchLoaded) {
      final currentState = state as TienIchLoaded;
      emit(currentState.copyWith(activeTab: tabIndex));
      if (tabIndex == 1) {
        fetchAmenitiesData(residentId: residentId, targetTab: 1);
      }
    } else {
      fetchAmenitiesData(residentId: residentId, targetTab: tabIndex);
    }
  }

  Future<String?> bookAmenity({
    required String amenityId,
    required String residentId,
    required DateTime startTime,
    required DateTime endTime,
    int numberOfGuests = 1,
  }) async {
    try {
      final bookingId = await bookAmenityUseCase.execute(
        amenityId: amenityId,
        residentId: residentId,
        startTime: startTime,
        endTime: endTime,
        numberOfGuests: numberOfGuests,
      );
      emit(BookingSuccessState("Đặt lịch tiện ích thành công!", bookingId: bookingId));
      await fetchAmenitiesData(residentId: residentId, targetTab: 1);
      return bookingId;
    } catch (e) {
      emit(TienIchError(e.toString().replaceAll('Exception: ', '')));
      return null;
    }
  }

  Future<void> cancelBooking(String bookingId, {String residentId = 'Res1'}) async {
    try {
      final success = await cancelBookingUseCase.execute(bookingId);
      if (success) {
        emit(const BookingSuccessState("Hủy lịch đặt tiện ích thành công!"));
        await fetchAmenitiesData(residentId: residentId, targetTab: 1);
      }
    } catch (e) {
      emit(TienIchError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
