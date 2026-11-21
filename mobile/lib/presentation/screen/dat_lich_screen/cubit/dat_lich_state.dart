import 'package:equatable/equatable.dart';

class DatLichState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? bookingId;
  final int selectedTabIndex;
  final String bookingCode;
  final String qrData;
  final String ticketCodeText;
  final int remainingSeconds;
  final int maxSeconds;
  final String statusText;
  final String blockName;
  final String amenityTitle;
  final String locationText;
  final String timeRange;
  final String bookingDate;
  final String apartmentNumber;
  final String residentName;
  final int numberOfGuests;
  final int maxCapacity;
  final String idCardNumber;
  final String feeText;
  final bool isCancelled;
  final String? toastMessage;
  final String? amenityImageUrl;

  const DatLichState({
    this.isLoading = false,
    this.errorMessage,
    this.bookingId,
    this.selectedTabIndex = 0,
    this.bookingCode = "",
    this.qrData = "",
    this.ticketCodeText = "",
    this.remainingSeconds = 60,
    this.maxSeconds = 60,
    this.statusText = "ĐÃ XÁC NHẬN",
    this.blockName = "KHỐI RUBY SUITES",
    this.amenityTitle = "",
    this.locationText = "",
    this.timeRange = "",
    this.bookingDate = "",
    this.apartmentNumber = "",
    this.residentName = "",
    this.numberOfGuests = 10,
    this.maxCapacity = 20,
    this.idCardNumber = "",
    this.feeText = "Miễn phí cư dân (Ruby Privilege)",
    this.isCancelled = false,
    this.toastMessage,
    this.amenityImageUrl,
  });

  DatLichState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? bookingId,
    int? selectedTabIndex,
    String? bookingCode,
    String? qrData,
    String? ticketCodeText,
    int? remainingSeconds,
    int? maxSeconds,
    String? statusText,
    String? blockName,
    String? amenityTitle,
    String? locationText,
    String? timeRange,
    String? bookingDate,
    String? apartmentNumber,
    String? residentName,
    int? numberOfGuests,
    int? maxCapacity,
    String? idCardNumber,
    String? feeText,
    bool? isCancelled,
    String? toastMessage,
    String? amenityImageUrl,
  }) {
    return DatLichState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      bookingId: bookingId ?? this.bookingId,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      bookingCode: bookingCode ?? this.bookingCode,
      qrData: qrData ?? this.qrData,
      ticketCodeText: ticketCodeText ?? this.ticketCodeText,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      maxSeconds: maxSeconds ?? this.maxSeconds,
      statusText: statusText ?? this.statusText,
      blockName: blockName ?? this.blockName,
      amenityTitle: amenityTitle ?? this.amenityTitle,
      locationText: locationText ?? this.locationText,
      timeRange: timeRange ?? this.timeRange,
      bookingDate: bookingDate ?? this.bookingDate,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      residentName: residentName ?? this.residentName,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      feeText: feeText ?? this.feeText,
      isCancelled: isCancelled ?? this.isCancelled,
      toastMessage: toastMessage,
      amenityImageUrl: amenityImageUrl ?? this.amenityImageUrl,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        bookingId,
        selectedTabIndex,
        bookingCode,
        qrData,
        ticketCodeText,
        remainingSeconds,
        maxSeconds,
        statusText,
        blockName,
        amenityTitle,
        locationText,
        timeRange,
        bookingDate,
        apartmentNumber,
        residentName,
        numberOfGuests,
        maxCapacity,
        idCardNumber,
        feeText,
        isCancelled,
        toastMessage,
        amenityImageUrl,
      ];
}
