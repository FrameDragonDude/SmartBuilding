class LoginRequestModel {
  final String usernameOrEmail;
  final String password;

  LoginRequestModel({
    required this.usernameOrEmail,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    };
  }
}

class RegisterRequestModel {
  final String fullName;
  final String? identityCardNumber;
  final String phoneNumber;
  final String email;
  final String username;
  final String password;

  RegisterRequestModel({
    required this.fullName,
    this.identityCardNumber,
    required this.phoneNumber,
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'identityCardNumber': identityCardNumber ?? '',
      'phoneNumber': phoneNumber,
      'email': email,
      'username': username,
      'password': password,
    };
  }
}

class AuthResponseModel {
  final String accountId;
  final String? residentId;
  final String username;
  final String email;
  final String fullName;
  final String message;

  AuthResponseModel({
    required this.accountId,
    this.residentId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accountId: json['accountId'] ?? '',
      residentId: json['residentId'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
