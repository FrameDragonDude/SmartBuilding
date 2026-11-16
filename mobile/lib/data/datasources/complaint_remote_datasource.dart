import 'package:dio/dio.dart';
import '../../common/network/api_client.dart';
import '../model/complaint_data_model.dart';
import '../url/api_urls.dart';

abstract class IComplaintRemoteDataSource {
  Future<ComplaintSummaryDataModel> getComplaints({
    String residentId = 'Res1',
    String? category,
    String? status,
  });

  Future<bool> createComplaint({
    required String residentId,
    required String category,
    required String title,
    required String content,
    String? attachedImageUrl,
  });
}

class ComplaintRemoteDataSourceImpl implements IComplaintRemoteDataSource {
  final ApiClient apiClient;

  ComplaintRemoteDataSourceImpl({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  @override
  Future<ComplaintSummaryDataModel> getComplaints({
    String residentId = 'Res1',
    String? category,
    String? status,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiUrls.complaints,
        queryParameters: {
          'residentId': residentId,
          if (category != null && category.isNotEmpty) 'category': category,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      return ComplaintSummaryDataModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải danh sách khiếu nại: $e');
    }
  }

  @override
  Future<bool> createComplaint({
    required String residentId,
    required String category,
    required String title,
    required String content,
    String? attachedImageUrl,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiUrls.createComplaint,
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
