class UserModel {
  final String email;
  final String character;
  final String name;
  final int points;
  final Map<String, int> categoryPoints; // Add this field

  UserModel({
    required this.email,
    required this.character,
    required this.name,
    required this.points,
    required this.categoryPoints, // Include in the constructor
  });

  // Convert UserModel to a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'character': character,
      'name': name,
      'points': points,
      'categoryPoints': categoryPoints, // Store the category points
    };
  }

  // Create a UserModel from a Firestore document map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      character: map['character'] ?? '',
      name: map['name'] ?? '',
      points: map['points'] ?? 20,
      categoryPoints: Map<String, int>.from(map['categoryPoints'] ?? {}), // Safely map category points
    );
  }

  @override
  String toString() {
    return 'UserModel(email: $email, character: $character, name: $name, points: $points, categoryPoints: $categoryPoints)';
  }
}
