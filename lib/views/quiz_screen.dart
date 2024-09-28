import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
import '../controller/all_db_controller.dart';
import '../controller/quiz_controller.dart';
import '../model/quiz_model.dart';

const int pointsPerCorrectAnswer = 5;
const int questionTimeLimit = 10; // Time limit per question in seconds

class QuizScreen extends StatefulWidget {
  final List<QuizModel> quizzes;
  final String category;

  QuizScreen({required this.quizzes, required this.category});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizController _quizController = QuizController();
  final AllDBController _dbController = AllDBController();
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _isAnswerSubmitted = false;
  String? _correctAnswer;
  Timer? _timer;
  int _remainingTime = questionTimeLimit;

  @override
  void initState() {
    super.initState();
    _loadCurrentQuestionIndex();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
  }

  Future<void> _loadCurrentQuestionIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedIndex = prefs.getInt('${widget.category}_currentQuestionIndex') ?? 0;
    setState(() {
      _currentQuestionIndex = savedIndex < widget.quizzes.length ? savedIndex : 0;
    });
    _startTimer();
  }

  Future<void> _saveCurrentQuestionIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${widget.category}_currentQuestionIndex', _currentQuestionIndex);
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    setState(() {
      _remainingTime = questionTimeLimit;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime <= 1) {
        timer.cancel();
        _autoMoveToNextQuestion();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _autoMoveToNextQuestion() {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Time\'s up! Moving to the next question.')),
    // );
    _moveToNextQuestion();
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
      _timer?.cancel(); // Cancel the timer as the user has submitted an answer
      try {
        if (_selectedAnswer == correctAnswer) {
          await _quizController.addPoints(userEmail, pointsPerCorrectAnswer);
          _moveToNextQuestion();
        } else {
          setState(() {
            _isAnswerSubmitted = true;
            _correctAnswer = correctAnswer;
          });
          _showCorrectAnswerDialog();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
        print('Error updating points: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
      // Optionally redirect to login screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoginScreen()),
      // );
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
      _startTimer(); // Restart the timer for the next question
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    _timer?.cancel(); // Cancel any existing timer
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
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
      barrierDismissible: true, // Allow dismissal by tapping outside
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close the dialog
            _moveToNextQuestion(); // Move to the next question
          },
          child: AlertDialog(
            title: Text('Incorrect Answer'),
            content: Text('The correct answer is: $_correctAnswer'),
          ),
        );
      },
    ).then((_) {
      // In case the dialog is dismissed by other means
      if (mounted) {
        _moveToNextQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz: ${widget.category}'),
        ),
        body: Center(
          child: Text('No quizzes available in this category.'),
        ),
      );
    }

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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center, // Optional: Adjust alignment
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Question Number and Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(
                //   'Question ${_currentQuestionIndex + 1}/${widget.quizzes.length}',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                // ),
                Row(
                  children: [
                    Icon(Icons.timer, color: Colors.red),
                    SizedBox(width: 5),
                    Text(
                      '$_remainingTime s',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // Display Question
            Text(
              quiz.question,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Display Answer Options
            Expanded(
              child: ListView(
                children: [quiz.optionA, quiz.optionB, quiz.optionC, quiz.optionD]
                    .map((option) => AnswerOption(
                  option: option,
                  selectedAnswer: _selectedAnswer,
                  isSubmitted: _isAnswerSubmitted,
                  correctAnswer: _correctAnswer,
                  onChanged: _isAnswerSubmitted
                      ? null
                      : (value) {
                    setState(() {
                      _selectedAnswer = value;
                    });
                  },
                ))
                    .toList(),
              ),
            ),
            SizedBox(height: 20),
            // Submit Button
            ElevatedButton(
              onPressed: (_isAnswerSubmitted || _remainingTime == 0) ? null : _checkAnswer,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Make button full-width
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate widget for Answer Options
class AnswerOption extends StatelessWidget {
  final String option;
  final String? selectedAnswer;
  final bool isSubmitted;
  final String? correctAnswer;
  final Function(String?)? onChanged;

  AnswerOption({
    required this.option,
    required this.selectedAnswer,
    required this.isSubmitted,
    required this.correctAnswer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color? tileColor;
    if (isSubmitted) {
      if (option == correctAnswer) {
        tileColor = Colors.green.withOpacity(0.3);
      } else if (option == selectedAnswer) {
        tileColor = Colors.red.withOpacity(0.3);
      }
    }

    return ListTile(
      title: Text(option),
      leading: Radio<String>(
        value: option,
        groupValue: selectedAnswer,
        onChanged: onChanged,
      ),
      tileColor: tileColor,
    );
  }
}
