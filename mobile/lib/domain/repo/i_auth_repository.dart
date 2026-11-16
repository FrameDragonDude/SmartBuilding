import '../../data/model/auth_models.dart';

abstract class IAuthRepository {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
}
