class HomeDataModel {
  final ResidentHomeModel? resident;
  final InvoiceHomeModel? invoice;
  final List<VehicleHomeModel> vehicles;
  final AmenityBookingHomeModel? upcomingBooking;
  final AnnouncementHomeModel? announcement;

  HomeDataModel({
    this.resident,
    this.invoice,
    this.vehicles = const [],
    this.upcomingBooking,
    this.announcement,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      resident: json['resident'] != null
          ? ResidentHomeModel.fromJson(json['resident'])
          : null,
      invoice: json['invoice'] != null
          ? InvoiceHomeModel.fromJson(json['invoice'])
          : null,
      vehicles: json['vehicles'] != null
          ? (json['vehicles'] as List)
              .map((v) => VehicleHomeModel.fromJson(v))
              .toList()
          : [],
      upcomingBooking: json['upcomingBooking'] != null
          ? AmenityBookingHomeModel.fromJson(json['upcomingBooking'])
          : null,
      announcement: json['announcement'] != null
          ? AnnouncementHomeModel.fromJson(json['announcement'])
          : null,
    );
  }
}

class ResidentHomeModel {
  final String residentId;
  final String fullName;
  final String apartmentNumber;
  final String floorNumber;
  final String buildingName;
  final String buildingCode;
  final double area;
  final String contractType;
  final String startDate;
  final String endDate;
  final String status;

  ResidentHomeModel({
    required this.residentId,
    required this.fullName,
    required this.apartmentNumber,
    required this.floorNumber,
    required this.buildingName,
    required this.buildingCode,
    required this.area,
    required this.contractType,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory ResidentHomeModel.fromJson(Map<String, dynamic> json) {
    return ResidentHomeModel(
      residentId: json['residentId'] ?? '',
      fullName: json['fullName'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      floorNumber: json['floorNumber'] ?? '',
      buildingName: json['buildingName'] ?? '',
      buildingCode: json['buildingCode'] ?? '',
      area: (json['area'] ?? 0).toDouble(),
      contractType: json['contractType'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      status: json['status'] ?? 'Đang hiệu lực',
    );
  }
}

class InvoiceHomeModel {
  final String invoiceCode;
  final int billingMonth;
  final int billingYear;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String paymentMethod;
  final String paymentDate;

  InvoiceHomeModel({
    required this.invoiceCode,
    required this.billingMonth,
    required this.billingYear,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentDate,
  });

  factory InvoiceHomeModel.fromJson(Map<String, dynamic> json) {
    return InvoiceHomeModel(
      invoiceCode: json['invoiceCode'] ?? '',
      billingMonth: json['billingMonth'] ?? 1,
      billingYear: json['billingYear'] ?? 2026,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unpaid',
      paymentMethod: json['paymentMethod'] ?? 'VNPay QR',
      paymentDate: json['paymentDate'] ?? '',
    );
  }
}

class VehicleHomeModel {
  final String vehicleId;
  final String brand;
  final String vehicleType;
  final String licensePlate;
  final String rfidCardCode;
  final bool isActive;
  final String slotCode;
  final String basementLevel;
  final double monthlyPrice;

  VehicleHomeModel({
    required this.vehicleId,
    required this.brand,
    required this.vehicleType,
    required this.licensePlate,
    required this.rfidCardCode,
    required this.isActive,
    required this.slotCode,
    required this.basementLevel,
    required this.monthlyPrice,
  });

  factory VehicleHomeModel.fromJson(Map<String, dynamic> json) {
    return VehicleHomeModel(
      vehicleId: json['vehicleId'] ?? '',
      brand: json['brand'] ?? '',
      vehicleType: json['vehicleType'] ?? 'Car',
      licensePlate: json['licensePlate'] ?? '',
      rfidCardCode: json['rfidCardCode'] ?? '',
      isActive: json['isActive'] ?? true,
      slotCode: json['slotCode'] ?? '',
      basementLevel: json['basementLevel'] ?? '',
      monthlyPrice: (json['monthlyPrice'] ?? 0).toDouble(),
    );
  }
}

class AmenityBookingHomeModel {
  final String bookingId;
  final String amenityName;
  final String amenityId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int numberOfGuests;
  final String status;

  AmenityBookingHomeModel({
    required this.bookingId,
    required this.amenityName,
    required this.amenityId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.numberOfGuests,
    required this.status,
  });

  factory AmenityBookingHomeModel.fromJson(Map<String, dynamic> json) {
    return AmenityBookingHomeModel(
      bookingId: json['bookingId'] ?? '',
      amenityName: json['amenityName'] ?? '',
      amenityId: json['amenityId'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      numberOfGuests: json['numberOfGuests'] ?? 1,
      status: json['status'] ?? 'Confirmed',
    );
  }
}

class AnnouncementHomeModel {
  final String title;
  final String date;
  final String content;
  final String hotline;

  AnnouncementHomeModel({
    required this.title,
    required this.date,
    required this.content,
    required this.hotline,
  });

  factory AnnouncementHomeModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementHomeModel(
      title: json['title'] ?? '',
      date: json['date'] ?? 'Hôm nay',
      content: json['content'] ?? '',
      hotline: json['hotline'] ?? '1900 8899',
    );
  }
}
