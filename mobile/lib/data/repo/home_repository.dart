import '../../common/network/api_client.dart';
import '../model/home_data_model.dart';

class HomeRepository {
  final ApiClient apiClient;

  HomeRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<HomeDataModel> getHomeData({String residentId = 'Res1'}) async {
    try {
      final response = await apiClient.dio.get(
        '/home',
        queryParameters: {'residentId': residentId},
      );
      return HomeDataModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải dữ liệu trang chủ: $e');
    }
  }
}
