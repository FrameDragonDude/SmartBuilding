import 'package:dio/dio.dart';
import '../../common/network/api_client.dart';
import '../model/amenity_data_model.dart';

class AmenityRepository {
  final ApiClient apiClient;

  AmenityRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<List<AmenityModel>> getAmenities() async {
    try {
      final response = await apiClient.dio.get('/amenities');
      final List data = response.data;
      return data.map((json) => AmenityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách tiện ích: $e');
    }
  }

  Future<List<AmenityBookingModel>> getMyBookings({String residentId = 'Res1'}) async {
    try {
      final response = await apiClient.dio.get(
        '/amenities/my-bookings',
        queryParameters: {'residentId': residentId},
      );
      final List data = response.data;
      return data.map((json) => AmenityBookingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải lịch đặt tiện ích: $e');
    }
  }

  Future<bool> bookAmenity({
    required String amenityId,
    required String residentId,
    required DateTime startTime,
    required DateTime endTime,
    int numberOfGuests = 1,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/amenities/book',
        data: {
          'amenityId': amenityId,
          'residentId': residentId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'numberOfGuests': numberOfGuests,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Đặt lịch thất bại!';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi đặt lịch tiện ích: $e');
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      final response = await apiClient.dio.post('/amenities/bookings/$bookingId/cancel');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Hủy lịch đặt thất bại: $e');
    }
  }
}
