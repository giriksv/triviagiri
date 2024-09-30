import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/single_player_quiz_model.dart';
import '../services/local_db_service.dart';

class AllDBController {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  Future<void> insertUserData(UserModel user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.email).set({
        'selectedCharacter': user.character,
        'email': user.email,
        'name': user.name, // Store the exact user name
      }, SetOptions(merge: true));
      print("User data inserted/updated for: ${user.email}");
    } catch (e) {
      print("Error inserting user data: $e");
      rethrow; // Optionally rethrow to handle it upstream
    }
  }

  Future<List<QuizModel>> getQuizzesByCategory(String category) async {
    return await _dbService.getQuizzesByCategory(category);
  }

  Future<void> addPoints(String email, int points, String category) async {
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'points': FieldValue.increment(points),
      'categories': {
        category: FieldValue.increment(points),
      },
    }, SetOptions(merge: true));
  }

  Future<void> clearAndCreateDb(List<QuizModel> quizzes) async {
    await _dbService.clearAndCreateDb(quizzes);
  }

  Future<void> updateUserTimestamp(String email) async {
    await FirebaseFirestore.instance.collection('users').doc(email).update({
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }
}