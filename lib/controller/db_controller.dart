import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/quiz_model.dart';
import '../services/db_service.dart';

class DBController {
  final DatabaseService _dbService = DatabaseService();

  Future<void> insertUserData(String email, String character) async {
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'selectedCharacter': character,
      'email': email,
    }, SetOptions(merge: true));
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
}
