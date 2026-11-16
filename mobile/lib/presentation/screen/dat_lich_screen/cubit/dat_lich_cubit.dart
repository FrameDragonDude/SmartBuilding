import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/amenity_repository.dart';
import '../../../../domain/entities/amenity_booking_detail.dart';
import '../../../../domain/usecases/cancel_booking_usecase.dart';
import '../../../../domain/usecases/get_booking_detail_usecase.dart';
import '../../../../domain/usecases/get_latest_booking_detail_usecase.dart';
import 'dat_lich_state.dart';

class DatLichCubit extends Cubit<DatLichState> {
  final GetBookingDetailUseCase getBookingDetailUseCase;
  final GetLatestBookingDetailUseCase getLatestBookingDetailUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  Timer? _timer;

  DatLichCubit({
    GetBookingDetailUseCase? getBookingDetailUseCase,
    GetLatestBookingDetailUseCase? getLatestBookingDetailUseCase,
    CancelBookingUseCase? cancelBookingUseCase,
  })  : getBookingDetailUseCase = getBookingDetailUseCase ?? GetBookingDetailUseCase(AmenityRepository()),
        getLatestBookingDetailUseCase = getLatestBookingDetailUseCase ?? GetLatestBookingDetailUseCase(AmenityRepository()),
        cancelBookingUseCase = cancelBookingUseCase ?? CancelBookingUseCase(AmenityRepository()),
        super(const DatLichState()) {
    _startTimer();
  }

  Future<void> fetchBookingDetail({String? bookingId, String residentId = 'Res1'}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final AmenityBookingDetail detail;
      if (bookingId != null && bookingId.isNotEmpty) {
        detail = await getBookingDetailUseCase.execute(bookingId);
      } else {
        detail = await getLatestBookingDetailUseCase.execute(residentId: residentId);
      }

      final isCancelled = detail.status.toLowerCase() == 'cancelled';

      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        bookingId: detail.id,
        bookingCode: detail.bookingCode,
        blockName: detail.blockName,
        amenityTitle: detail.amenityTitle,
        locationText: detail.locationText,
        timeRange: detail.timeRange,
        bookingDate: detail.bookingDate,
        apartmentNumber: detail.apartmentNumber,
        residentName: detail.residentName,
        numberOfGuests: detail.numberOfGuests,
        maxCapacity: detail.maxCapacity,
        idCardNumber: detail.idCardNumber,
        feeText: detail.feeText,
        statusText: detail.statusText,
        ticketCodeText: detail.ticketCodeText,
        qrData: detail.qrData,
        isCancelled: isCancelled,
        amenityImageUrl: detail.amenityImageUrl,
        remainingSeconds: state.maxSeconds,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thông tin vé tiện ích từ máy chủ. Vui lòng kiểm tra lại kết nối.',
      ));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) return;
      if (state.remainingSeconds > 1) {
        emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
      } else {
        refreshQrCode();
      }
    });
  }

  void refreshQrCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomHash = Random().nextInt(900000) + 100000;
    final baseQr = state.ticketCodeText.replaceAll(' ', '');
    final newQrData = "$baseQr-$timestamp-$randomHash";
    emit(state.copyWith(
      qrData: newQrData,
      remainingSeconds: state.maxSeconds,
    ));
  }

  void selectTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void saveQrToGallery() {
    emit(state.copyWith(toastMessage: "Đã lưu mã QR vào thư viện ảnh!"));
  }

  void shareTicketCode() {
    emit(state.copyWith(toastMessage: "Đã sao chép link chia sẻ mã vé cho ${state.numberOfGuests} khách!"));
  }

  Future<void> cancelBooking() async {
    final currentBookingId = state.bookingId;
    if (currentBookingId != null && currentBookingId.isNotEmpty) {
      try {
        final success = await cancelBookingUseCase.execute(currentBookingId);
        if (success) {
          emit(state.copyWith(
            isCancelled: true,
            statusText: "ĐÃ HỦY",
            toastMessage: "Đã hủy lịch đặt tiện ích thành công trên hệ thống",
          ));
          return;
        }
      } catch (_) {}
    }

    emit(state.copyWith(
      isCancelled: true,
      statusText: "ĐÃ HỦY",
      toastMessage: "Đã hủy lịch đặt tiện ích thành công",
    ));
  }

  void clearToast() {
    emit(state.copyWith(toastMessage: null));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
