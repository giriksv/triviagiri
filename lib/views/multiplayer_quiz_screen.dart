import 'package:flutter/material.dart';
import '../controller/MultiplayerQuizController.dart';
import 'ViewResultsScreen.dart';

class MultiplayerQuizScreen extends StatefulWidget {
  final String roomId;
  final String category;
  final String userEmail;

  MultiplayerQuizScreen({
    required this.roomId,
    required this.category,
    required this.userEmail,
  });

  @override
  _MultiplayerQuizScreenState createState() => _MultiplayerQuizScreenState();
}

class _MultiplayerQuizScreenState extends State<MultiplayerQuizScreen> {
  final MultiplayerQuizController controller = MultiplayerQuizController();
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _roomPoints = 0;
  bool _isQuizCompleted = false;
  String? _selectedAnswer;
  String? _correctAnswer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await controller.loadQuestions();
    setState(() {
      _questions = questions;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    String correctAnswer = _questions[_currentQuestionIndex]['correctAnswer'];
    setState(() {
      _correctAnswer = correctAnswer;
    });

    controller.submitAnswer(
      selectedAnswer: _selectedAnswer!,
      correctAnswer: correctAnswer,
      onCorrect: () async {
        setState(() {
          _roomPoints += 5;
        });

        await controller.updateRoomPoints(widget.roomId, widget.userEmail);
        await controller.updateUserPoints(widget.userEmail);

        if (_currentQuestionIndex < _questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _selectedAnswer = null;
          });
        } else {
          setState(() {
            _isQuizCompleted = true;
          });
        }
      },
      onIncorrect: () {
        if (_currentQuestionIndex < _questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _selectedAnswer = null;
          });
        } else {
          setState(() {
            _isQuizCompleted = true;
          });
        }
      },
    );
  }

  Widget _buildOptionButton(String optionText, String optionValue) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedAnswer = optionValue;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedAnswer == optionValue
            ? Colors.green.shade300
            : Colors.grey.shade300,
      ),
      child: Text(optionText),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Quiz"),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz"),
      ),
      body: Column(
        children: [
          if (_isQuizCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewResultsScreen(roomId: widget.roomId)),
                );
              },
              child: Text('View Results'),
            )
          else ...[
            Text("Question ${_currentQuestionIndex + 1}/5"),
            Text(_questions[_currentQuestionIndex]['question']),
            _buildOptionButton(
                _questions[_currentQuestionIndex]['optionA'],
                _questions[_currentQuestionIndex]['optionA']),
            _buildOptionButton(
                _questions[_currentQuestionIndex]['optionB'],
                _questions[_currentQuestionIndex]['optionB']),
            _buildOptionButton(
                _questions[_currentQuestionIndex]['optionC'],
                _questions[_currentQuestionIndex]['optionC']),
            _buildOptionButton(
                _questions[_currentQuestionIndex]['optionD'],
                _questions[_currentQuestionIndex]['optionD']),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: Text("Next"),
            ),
          ],
        ],
      ),
    );
  }
}
