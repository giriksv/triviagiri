import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/db_controller.dart';
import '../controller/quiz_controller.dart';
import '../model/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizModel> quizzes;
  final String category;

  QuizScreen({required this.quizzes, required this.category});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizController _quizController = QuizController();
  final DBController _dbController = DBController();
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _isAnswerSubmitted = false;
  String? _correctAnswer;

  void _checkAnswer() {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final correctAnswer = widget.quizzes[_currentQuestionIndex].correctAnswer;

    if (_selectedAnswer == null) {
      // Handle case where no option is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an answer!')),
      );
      return;
    }

    if (userEmail != null) {
      if (_selectedAnswer == correctAnswer) {
        _quizController.addPoints(userEmail, 5);
        _moveToNextQuestion();
      } else {
        setState(() {
          _isAnswerSubmitted = true;
          _correctAnswer = correctAnswer;
        });
        _showCorrectAnswerDialog();
      }
    } else {
      print('User not logged in');
    }
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < widget.quizzes.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerSubmitted = false;
        _correctAnswer = null;
        _selectedAnswer = null; // Reset selected answer
      });
    } else {
      // Handle the end of the quiz (e.g., navigate to a results screen)
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Quiz Completed'),
            content: Text('You have completed the quiz!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Optionally navigate to results screen here
                },
                child: Text('Finish'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Incorrect Answer'),
          content: Text('The correct answer is: $_correctAnswer'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _moveToNextQuestion(); // Move to the next question
              },
              child: Text('Next Question'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quizzes[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: Container(
        color: Colors.lightBlueAccent, // Background color
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              quiz.question,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(quiz.optionA),
              leading: Radio<String>(
                value: quiz.optionA,
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(quiz.optionB),
              leading: Radio<String>(
                value: quiz.optionB,
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(quiz.optionC),
              leading: Radio<String>(
                value: quiz.optionC,
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(quiz.optionD),
              leading: Radio<String>(
                value: quiz.optionD,
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
