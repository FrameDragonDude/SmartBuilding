class AmenityBookingModel {
  final String id;
  final String amenityId;
  final String amenityName;
  final String? amenityImageUrl;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int numberOfGuests;
  final String status;

  AmenityBookingModel({
    required this.id,
    required this.amenityId,
    required this.amenityName,
    this.amenityImageUrl,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.numberOfGuests,
    required this.status,
  });

  factory AmenityBookingModel.fromJson(Map<String, dynamic> json) {
    return AmenityBookingModel(
      id: json['id'] ?? '',
      amenityId: json['amenityId'] ?? '',
      amenityName: json['amenityName'] ?? '',
      amenityImageUrl: json['amenityImageUrl'],
      bookingDate: json['bookingDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      numberOfGuests: json['numberOfGuests'] ?? 1,
      status: json['status'] ?? 'Confirmed',
    );
  }
}

class AmenityBookingDetailModel {
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

  AmenityBookingDetailModel({
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

  factory AmenityBookingDetailModel.fromJson(Map<String, dynamic> json) {
    return AmenityBookingDetailModel(
      id: json['id'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      amenityId: json['amenityId'] ?? '',
      blockName: json['blockName'] ?? 'KHỐI RUBY SUITES',
      amenityTitle: json['amenityTitle'] ?? '',
      locationText: json['locationText'] ?? '',
      timeRange: json['timeRange'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      residentName: json['residentName'] ?? '',
      numberOfGuests: json['numberOfGuests'] ?? 0,
      maxCapacity: json['maxCapacity'] ?? 20,
      idCardNumber: json['idCardNumber'] ?? '',
      feeText: json['feeText'] ?? 'Miễn phí cư dân (Ruby Privilege)',
      status: json['status'] ?? 'Confirmed',
      statusText: json['statusText'] ?? 'ĐÃ XÁC NHẬN',
      ticketCodeText: json['ticketCodeText'] ?? '',
      qrData: json['qrData'] ?? '',
      amenityImageUrl: json['amenityImageUrl'],
    );
  }
}
