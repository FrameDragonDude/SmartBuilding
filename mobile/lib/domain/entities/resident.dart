class Resident {
  final String id;
  final String fullName;
  final String identityCardNumber;
  final String phoneNumber;
  final String? email;
  final String dateOfBirth;
  final String gender;
  final String? avatarUrl;

  Resident({
    required this.id,
    required this.fullName,
    required this.identityCardNumber,
    required this.phoneNumber,
    this.email,
    required this.dateOfBirth,
    required this.gender,
    this.avatarUrl,
  });
}
