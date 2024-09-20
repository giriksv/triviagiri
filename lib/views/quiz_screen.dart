import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/db_controller.dart';
import '../controller/quiz_controller.dart';
import '../model/quiz_model.dart';

class QuizScreen extends StatelessWidget {
  final List<QuizModel> quizzes;
  final String category; // Add a category variable
  final QuizController _quizController = QuizController();
  final DBController _dbController = DBController();

  QuizScreen({required this.quizzes, required this.category}); // Accept category in constructor

  void _checkAnswer(BuildContext context, String selectedAnswer, String correctAnswer) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      _quizController.checkAnswer(selectedAnswer, correctAnswer, userEmail); // Update method call
      if (selectedAnswer == correctAnswer) {
        // Add points to Firestore under the user's email
        _dbController.addPoints(userEmail, 5, category);
        // Navigate to next question or show result
      }
    } else {
      // Handle the case where the user is not logged in
      print('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return Card(
            child: ListTile(
              title: Text(quiz.question),
              subtitle: Column(
                children: [
                  ElevatedButton(onPressed: () => _checkAnswer(context, quiz.optionA, quiz.correctAnswer), child: Text(quiz.optionA)),
                  ElevatedButton(onPressed: () => _checkAnswer(context, quiz.optionB, quiz.correctAnswer), child: Text(quiz.optionB)),
                  ElevatedButton(onPressed: () => _checkAnswer(context, quiz.optionC, quiz.correctAnswer), child: Text(quiz.optionC)),
                  ElevatedButton(onPressed: () => _checkAnswer(context, quiz.optionD, quiz.correctAnswer), child: Text(quiz.optionD)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
