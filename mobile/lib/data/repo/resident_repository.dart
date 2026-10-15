import '../../common/network/api_client.dart';
import '../model/resident_model.dart';

class ResidentRepository {
  final ApiClient apiClient = ApiClient();

  Future<List<ResidentModel>> getResidents({String search = ''}) async {
    try {
      final response = await apiClient.dio.get(
        '/residents',
        queryParameters: {'search': search},
      );
      final List data = response.data;
      return data.map((json) => ResidentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load residents: $e');
    }
  }
}
