import '../../data/model/auth_models.dart';
import '../../domain/entities/user_entity.dart';

extension AuthMapper on AuthResponseModel {
  UserEntity toEntity() {
    return UserEntity(
      accountId: accountId,
      residentId: residentId,
      username: username,
      email: email,
      fullName: fullName,
      message: message,
    );
  }
}
