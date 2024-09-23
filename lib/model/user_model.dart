class UserModel {
  final String email;
  final String character;
  final String name;

  UserModel({
    required this.email,
    required this.character,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'character': character,
      'name': name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      character: map['character'] ?? '',
      name: map['name'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserModel(email: $email, character: $character, name: $name)';
  }
}
