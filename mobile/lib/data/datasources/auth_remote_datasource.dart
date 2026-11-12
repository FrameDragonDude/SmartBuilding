import 'package:dio/dio.dart';
import '../../common/network/api_client.dart';
import '../model/auth_models.dart';
import '../url/api_urls.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await apiClient.dio.post(
        ApiUrls.login,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Tên đăng nhập hoặc mật khẩu không chính xác!';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await apiClient.dio.post(
        ApiUrls.register,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.response?.data?['detail'] ?? 'Đăng ký thất bại!';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi đăng ký tài khoản: $e');
    }
  }
}
