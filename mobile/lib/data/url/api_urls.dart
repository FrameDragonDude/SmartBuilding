class ApiUrls {
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Amenities & Booking Endpoints
  static const String amenities = '/amenities';
  static const String myBookings = '/amenities/my-bookings';
  static const String bookAmenity = '/amenities/book';
  static const String latestBookingDetail = '/amenities/bookings/latest-detail';

  static String bookingDetail(String bookingId) => '/amenities/bookings/$bookingId/detail';
  static String cancelBooking(String bookingId) => '/amenities/bookings/$bookingId/cancel';

  // Invoices Endpoints
  static const String residentInvoices = '/invoices/resident';
  static String invoiceDetail(String invoiceId) => '/invoices/$invoiceId/resident-detail';
  static String payInvoice(String invoiceId) => '/invoices/$invoiceId/pay';

  // Complaints Endpoints
  static const String complaints = '/complaints';
  static const String createComplaint = '/complaints/create';

  // Resident Endpoints
  static String residentProfile(String residentId) => '/residents/$residentId/profile';
  static const String registerVehicle = '/residents/register-vehicle';

  // Home Endpoints
  static const String homeData = '/home';
}
