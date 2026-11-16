import '../../data/model/auth_models.dart';
import '../repo/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthResponseModel> execute(RegisterRequestModel request) async {
    return await repository.register(request);
  }
}
