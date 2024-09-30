// controller/single_player_quiz_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/single_player_quiz_model.dart';

class QuizController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPoints(String email, int points) async {
    try {
      // Use the user's email as the document ID
      DocumentReference userDoc = _firestore.collection('users').doc(email);

      // Update the points
      await userDoc.set({
        'points': FieldValue.increment(points),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error adding points: $e");
    }
  }

  void checkAnswer(
      String selectedAnswer, String correctAnswer, String userEmail) {
    if (selectedAnswer == correctAnswer) {
      addPoints(userEmail, 5); // Add 5 points for a correct answer
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