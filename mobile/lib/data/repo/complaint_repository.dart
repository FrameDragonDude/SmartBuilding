import 'package:dio/dio.dart';
import '../../common/network/api_client.dart';
import '../model/complaint_data_model.dart';

class ComplaintRepository {
  final ApiClient apiClient;

  ComplaintRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<ComplaintSummaryDataModel> getComplaints({
    String residentId = 'Res1',
    String? status,
    String? category,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/complaints',
        queryParameters: {
          'residentId': residentId,
          if (status != null && status.isNotEmpty) 'status': status,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      return ComplaintSummaryDataModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải danh sách khiếu nại: $e');
    }
  }

  Future<bool> createComplaint({
    required String residentId,
    required String title,
    required String content,
    String category = 'Sanitation',
    String? attachedImageUrl,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/complaints',
        data: {
          'residentId': residentId,
          'category': category,
          'title': title,
          'content': content,
          'attachedImageUrl': attachedImageUrl,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Gửi khiếu nại thất bại!';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi gửi khiếu nại: $e');
    }
  }
}
