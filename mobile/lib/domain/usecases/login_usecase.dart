import '../../data/model/auth_models.dart';
import '../../domain/repo/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResponseModel> execute(LoginRequestModel request) async {
    return await repository.login(request);
  }
}
