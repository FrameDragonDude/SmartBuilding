import 'package:dio/dio.dart';
import '../../common/network/api_client.dart';
import '../model/amenity_model.dart';
import '../model/amenity_data_model.dart';
import '../url/api_urls.dart';

abstract class IAmenityRemoteDataSource {
  Future<List<AmenityModel>> getAmenities();
  Future<List<AmenityBookingModel>> getMyBookings({String residentId = 'Res1'});
  Future<AmenityBookingDetailModel> getBookingDetail(String bookingId);
  Future<AmenityBookingDetailModel> getLatestBookingDetail({String residentId = 'Res1'});
  Future<String> bookAmenity({
    required String amenityId,
    required String residentId,
    required DateTime startTime,
    required DateTime endTime,
    int numberOfGuests = 1,
  });
  Future<bool> cancelBooking(String bookingId);
}

class AmenityRemoteDataSourceImpl implements IAmenityRemoteDataSource {
  final ApiClient apiClient;

  AmenityRemoteDataSourceImpl({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  @override
  Future<List<AmenityModel>> getAmenities() async {
    try {
      final response = await apiClient.dio.get(ApiUrls.amenities);
      final List data = response.data;
      return data.map((json) => AmenityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách tiện ích: $e');
    }
  }

  @override
  Future<List<AmenityBookingModel>> getMyBookings({String residentId = 'Res1'}) async {
    try {
      final response = await apiClient.dio.get(
        ApiUrls.myBookings,
        queryParameters: {'residentId': residentId},
      );
      final List data = response.data;
      return data.map((json) => AmenityBookingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải lịch đặt tiện ích: $e');
    }
  }

  @override
  Future<AmenityBookingDetailModel> getBookingDetail(String bookingId) async {
    try {
      final response = await apiClient.dio.get(ApiUrls.bookingDetail(bookingId));
      return AmenityBookingDetailModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải chi tiết vé tiện ích: $e');
    }
  }

  @override
  Future<AmenityBookingDetailModel> getLatestBookingDetail({String residentId = 'Res1'}) async {
    try {
      final response = await apiClient.dio.get(
        ApiUrls.latestBookingDetail,
        queryParameters: {'residentId': residentId},
      );
      return AmenityBookingDetailModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải chi tiết vé mới nhất: $e');
    }
  }

  @override
  Future<String> bookAmenity({
    required String amenityId,
    required String residentId,
    required DateTime startTime,
    required DateTime endTime,
    int numberOfGuests = 1,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiUrls.bookAmenity,
        data: {
          'amenityId': amenityId,
          'residentId': residentId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'numberOfGuests': numberOfGuests,
        },
      );
      final data = response.data;
      if (data is Map && data.containsKey('bookingId')) {
        return data['bookingId'].toString();
      }
      return 'AB_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Đặt lịch thất bại!';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi đặt lịch tiện ích: $e');
    }
  }

  @override
  Future<bool> cancelBooking(String bookingId) async {
    try {
      final response = await apiClient.dio.post(ApiUrls.cancelBooking(bookingId));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Hủy lịch đặt thất bại: $e');
    }
  }
}
