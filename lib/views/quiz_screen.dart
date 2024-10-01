import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/background_color_utils.dart';
import '../utils/custom_app_bar.dart';
import 'settings_screen.dart';
import '../controller/all_db_controller.dart';
import '../controller/single_player_quiz_controller.dart';
import '../model/single_player_quiz_model.dart';

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
    _timer?.cancel();
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
    _timer?.cancel();
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
      _timer?.cancel();
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
      _saveCurrentQuestionIndex();
      _startTimer();
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz Completed'),
          content: Text('You have completed the quiz!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetQuiz();
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
    await prefs.remove('${widget.category}_currentQuestionIndex');
    Navigator.pop(context);
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            _moveToNextQuestion();
          },
          child: AlertDialog(
            title: Text('Incorrect Answer'),
            content: Text('The correct answer is: $_correctAnswer'),
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        _moveToNextQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizzes.isEmpty) {
      return Scaffold(
        appBar: customAppBar(), // Fixed AppBar
        backgroundColor: BackgroundColorUtils.backgroundColor,
        body: Center(
          child: Text('No quizzes available in this category.'),
        ),
      );
    }

    final quiz = widget.quizzes[_currentQuestionIndex];

    return Scaffold(
      appBar: customAppBar(), // Fixed AppBar
      backgroundColor: BackgroundColorUtils.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quiz',
                  style: TextStyle(fontSize: 24, color: Color(0xFFC85E7E), fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.timer, color: Color(0xFFC85E7E)),
                    SizedBox(width: 5),
                    Text(
                      '$_remainingTime s',
                      style: TextStyle(fontSize: 18, color: Color(0xFFC85E7E)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Container
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: Color(0xFFFA7B95),
                        width: 4.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        quiz.question,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Answer Options as Buttons
                  Column(
                    children: [
                      ...[quiz.optionA, quiz.optionB, quiz.optionC, quiz.optionD].map(
                            (option) {
                          final isSelected = _selectedAnswer == option;
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ElevatedButton(
                              onPressed: _isAnswerSubmitted
                                  ? null
                                  : () {
                                setState(() {
                                  _selectedAnswer = option;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? Color(0xFFEAB834) : Color(0xFFFA7B95),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                option,
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: (_isAnswerSubmitted || _remainingTime == 0) ? null : _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF01CCCA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Submit Answer',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
