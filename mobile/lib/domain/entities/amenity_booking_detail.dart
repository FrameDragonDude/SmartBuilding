class AmenityBookingDetail {
  final String id;
  final String bookingCode;
  final String amenityId;
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
  final String status;
  final String statusText;
  final String ticketCodeText;
  final String qrData;
  final String? amenityImageUrl;

  const AmenityBookingDetail({
    required this.id,
    required this.bookingCode,
    required this.amenityId,
    required this.blockName,
    required this.amenityTitle,
    required this.locationText,
    required this.timeRange,
    required this.bookingDate,
    required this.apartmentNumber,
    required this.residentName,
    required this.numberOfGuests,
    required this.maxCapacity,
    required this.idCardNumber,
    required this.feeText,
    required this.status,
    required this.statusText,
    required this.ticketCodeText,
    required this.qrData,
    this.amenityImageUrl,
  });
}
