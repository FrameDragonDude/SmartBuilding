class UserEntity {
  final String accountId;
  final String? residentId;
  final String username;
  final String email;
  final String fullName;
  final String message;

  const UserEntity({
    required this.accountId,
    this.residentId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.message,
  });
}
