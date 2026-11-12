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
      bookingCode: json['bookingCode'] ?? '#AB1',
      amenityId: json['amenityId'] ?? '',
      blockName: json['blockName'] ?? 'KHỐI RUBY SUITES',
      amenityTitle: json['amenityTitle'] ?? 'Vườn Nướng BBQ Tầng Thượng',
      locationText: json['locationText'] ?? 'Bếp nướng BBQ-03 • Tầng 38 Tháp Ruby',
      timeRange: json['timeRange'] ?? '18:00 - 20:00',
      bookingDate: json['bookingDate'] ?? 'Hôm nay, 12/09/2026',
      apartmentNumber: json['apartmentNumber'] ?? 'Căn RB-0101',
      residentName: json['residentName'] ?? 'Nguyễn Văn An',
      numberOfGuests: json['numberOfGuests'] ?? 10,
      maxCapacity: json['maxCapacity'] ?? 20,
      idCardNumber: json['idCardNumber'] ?? '079095001234',
      feeText: json['feeText'] ?? 'Miễn phí cư dân (Ruby Privilege)',
      status: json['status'] ?? 'Confirmed',
      statusText: json['statusText'] ?? 'ĐÃ XÁC NHẬN',
      ticketCodeText: json['ticketCodeText'] ?? 'QR - AB1 - 20260912 - RB0101',
      qrData: json['qrData'] ?? 'QR-AB1-20260912-RB0101',
      amenityImageUrl: json['amenityImageUrl'],
    );
  }
}
