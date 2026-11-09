class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  String get displayName {
    final value = '$firstName $lastName'.trim();
    return value.isEmpty ? username : value;
  }
}
