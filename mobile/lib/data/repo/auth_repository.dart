import 'package:dio/dio.dart';
import '../../common/network/api_client.dart';
import '../model/auth_models.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
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

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
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
