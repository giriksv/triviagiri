import 'package:cloud_firestore/cloud_firestore.dart';

class QuizController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPoints(String email, int points) async {
    try {
      // Use the user's email as the document ID
      DocumentReference userDoc = _firestore.collection('users').doc(email);

      // Update the points
      await userDoc.set({
        'points': FieldValue.increment(points), // Increment points
      }, SetOptions(merge: true)); // Merge to keep existing data
    } catch (e) {
      print("Error adding points: $e");
    }
  }

  void checkAnswer(String selectedAnswer, String correctAnswer, String userEmail) {
    if (selectedAnswer == correctAnswer) {
      addPoints(userEmail, 5); // Add 5 points for a correct answer
    }
  }
}
