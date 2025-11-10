class UserInfo {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String country;

  UserInfo({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.country,
  });

  String get fullName => '$firstName $lastName';

  String get formattedDOB => '${dateOfBirth.month}/${dateOfBirth.day}/${dateOfBirth.year}';

  // Mock user for testing
  static UserInfo mockUser() {
    return UserInfo(
      firstName: 'Kiran',
      lastName: 'Addepalli',
      dateOfBirth: DateTime(1975, 10, 10),
      country: 'United States',
    );
  }
}
