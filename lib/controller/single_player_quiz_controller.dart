// controller/single_player_quiz_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/single_player_quiz_model.dart';
import 'all_db_controller.dart';

class QuizController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AllDBController _dbController = AllDBController();

  Future<void> addPoints(String email, int points, String category) async {
    try {
      // Update total points and category-specific points using AllDBController
      await _dbController.addPoints(email, points, category);
    } catch (e) {
      print("Error adding points: $e");
      rethrow;
    }
  }

  void checkAnswer(
      String selectedAnswer, String correctAnswer, String userEmail, String category) {
    if (selectedAnswer == correctAnswer) {
      addPoints(userEmail, 5, category); // Add 5 points for a correct answer
    }
  }

  // Optional method to get quizzes by category if needed
  Future<List<QuizModel>> getQuizzesByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching quizzes: $e");
      return [];
    }
  }
}
