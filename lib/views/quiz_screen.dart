import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCurrentQuestionIndex();
  }

  Future<void> _loadCurrentQuestionIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentQuestionIndex = prefs.getInt('${widget.category}_currentQuestionIndex') ?? 0;
    });
  }

  Future<void> _saveCurrentQuestionIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${widget.category}_currentQuestionIndex', _currentQuestionIndex);
  }

  void _checkAnswer() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final correctAnswer = widget.quizzes[_currentQuestionIndex].correctAnswer;

    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an answer!')),
      );
      return;
    }

    if (userEmail != null) {
      if (_selectedAnswer == correctAnswer) {
        await _quizController.addPoints(userEmail, 5);
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
        _selectedAnswer = null;
      });
      _saveCurrentQuestionIndex(); // Save index after moving to the next question
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz Completed'),
          content: Text('You have completed the quiz!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetQuiz(); // Reset quiz if needed
              },
              child: Text('Finish'),
            ),
          ],
        );
      },
    );
  }

  void _resetQuiz() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('${widget.category}_currentQuestionIndex'); // Reset index for the current category
    Navigator.pop(context); // Go back to the previous screen
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
                Navigator.of(context).pop();
                _moveToNextQuestion();
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
      appBar: AppBar(
        title: Text('Quiz: ${widget.category}'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              quiz.question,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...[quiz.optionA, quiz.optionB, quiz.optionC, quiz.optionD].map((option) {
              return ListTile(
                title: Text(option),
                leading: Radio<String>(
                  value: option,
                  groupValue: _selectedAnswer,
                  onChanged: (value) {
                    setState(() {
                      _selectedAnswer = value;
                    });
                  },
                ),
                tileColor: _isAnswerSubmitted && option == _correctAnswer
                    ? Colors.green.withOpacity(0.3)
                    : _isAnswerSubmitted && option == _selectedAnswer
                    ? Colors.red.withOpacity(0.3)
                    : null,
              );
            }).toList(),
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
