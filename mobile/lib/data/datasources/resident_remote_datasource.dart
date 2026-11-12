import 'package:dio/dio.dart';
import '../../common/network/api_client.dart';
import '../model/resident_profile_model.dart';
import '../url/api_urls.dart';

abstract class IResidentRemoteDataSource {
  Future<ResidentProfileDataModel> getResidentProfile(String residentId);

  Future<bool> registerVehicle({
    required String residentId,
    required String vehicleType,
    required String licensePlate,
    required String rfidCardCode,
    String? brand,
    String? slotCode,
  });
}

class ResidentRemoteDataSourceImpl implements IResidentRemoteDataSource {
  final ApiClient apiClient;

  ResidentRemoteDataSourceImpl({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  @override
  Future<ResidentProfileDataModel> getResidentProfile(String residentId) async {
    try {
      final response = await apiClient.dio.get(ApiUrls.residentProfile(residentId));
      return ResidentProfileDataModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải thông tin cư dân: $e');
    }
  }

  @override
  Future<bool> registerVehicle({
    required String residentId,
    required String vehicleType,
    required String licensePlate,
    required String rfidCardCode,
    String? brand,
    String? slotCode,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiUrls.registerVehicle,
        data: {
          'residentId': residentId,
          'vehicleType': vehicleType,
          'licensePlate': licensePlate,
          'rfidCardCode': rfidCardCode,
          'brand': brand,
          'slotCode': slotCode,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Đăng ký phương tiện thất bại!';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi đăng ký phương tiện: $e');
    }
  }
}
