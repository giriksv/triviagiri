// controller/all_db_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/single_player_quiz_model.dart';
import '../services/local_db_service.dart';

class AllDBController {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> insertUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.email).set({
        'selectedCharacter': user.character,
        'email': user.email,
        'name': user.name, // Store the exact user name
        'points': user.points ?? 0,
        'categoryPoints': user.categoryPoints ?? {},
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
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(email);

      await userDoc.set({
        'points': FieldValue.increment(points),
        'categoryPoints.$category': FieldValue.increment(points),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error adding points: $e");
      rethrow;
    }
  }

  Future<void> clearAndCreateDb(List<QuizModel> quizzes) async {
    await _dbService.clearAndCreateDb(quizzes);
  }

  Future<void> updateUserTimestamp(String email) async {
    await _firestore.collection('users').doc(email).update({
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }

  // New methods to get and set current question index for a category
  Future<int> getCurrentQuestionIndex(String email, String category) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(email).get();
      if (userDoc.exists) {
        return (userDoc.get('${category}QuizId') ?? 0) as int;
      } else {
        return 0;
      }
    } catch (e) {
      print("Error getting current question index: $e");
      return 0;
    }
  }

  Future<void> setCurrentQuestionIndex(String email, String category, int index) async {
    try {
      await _firestore.collection('users').doc(email).set({
        '${category}QuizId': index,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error setting current question index: $e");
      rethrow;
    }
  }
}
