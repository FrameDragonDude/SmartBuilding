import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/model/auth_models.dart';
import '../../../../domain/usecases/login_usecase.dart';
import '../../../../domain/usecases/register_usecase.dart';
import '../../../../data/repo/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthCubit({
    LoginUseCase? loginUseCase,
    RegisterUseCase? registerUseCase,
  })  : loginUseCase = loginUseCase ?? LoginUseCase(AuthRepository()),
        registerUseCase = registerUseCase ?? RegisterUseCase(AuthRepository()),
        super(AuthInitial());

  Future<void> login(String usernameOrEmail, String password) async {
    emit(AuthLoading());
    try {
      final request = LoginRequestModel(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );
      final user = await loginUseCase.execute(request);
      emit(AuthSuccess(user: user, message: user.message));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> register({
    required String fullName,
    String? identityCardNumber,
    required String phoneNumber,
    required String email,
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final request = RegisterRequestModel(
        fullName: fullName,
        identityCardNumber: identityCardNumber,
        phoneNumber: phoneNumber,
        email: email,
        username: username,
        password: password,
      );
      final user = await registerUseCase.execute(request);
      emit(AuthSuccess(user: user, message: user.message));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
