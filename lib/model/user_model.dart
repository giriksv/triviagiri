class UserModel {
  final String email;
  final String character;
  final String name;
  final int points;

  UserModel({
    required this.email,
    required this.character,
    required this.name,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'character': character,
      'name': name,
      'points':points,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      character: map['character'] ?? '',
      name: map['name'] ?? '',
      points: map['points'] ?? 20,
    );
  }

  @override
  String toString() {
    return 'UserModel(email: $email, character: $character, name: $name)';
  }
}
