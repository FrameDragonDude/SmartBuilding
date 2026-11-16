import '../../domain/repo/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../model/auth_models.dart';

class AuthRepository implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;

  AuthRepository({IAuthRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl();

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) {
    return remoteDataSource.login(request);
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) {
    return remoteDataSource.register(request);
  }
}
