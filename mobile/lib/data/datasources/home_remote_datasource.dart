import '../../common/network/api_client.dart';
import '../model/home_data_model.dart';
import '../url/api_urls.dart';

abstract class IHomeRemoteDataSource {
  Future<HomeDataModel> getHomeData({String residentId = 'Res1'});
}

class HomeRemoteDataSourceImpl implements IHomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  @override
  Future<HomeDataModel> getHomeData({String residentId = 'Res1'}) async {
    try {
      final response = await apiClient.dio.get(
        ApiUrls.homeData,
        queryParameters: {'residentId': residentId},
      );
      return HomeDataModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải dữ liệu trang chủ: $e');
    }
  }
}
