import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/model/auth_models.dart';
import '../../../../data/repo/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({AuthRepository? authRepository})
      : authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial());

  Future<void> login(String usernameOrEmail, String password) async {
    emit(AuthLoading());
    try {
      final request = LoginRequestModel(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );
      final response = await authRepository.login(request);
      emit(AuthSuccess(user: response, message: response.message));
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
      final response = await authRepository.register(request);
      emit(AuthSuccess(user: response, message: response.message));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
