import 'package:flutter/material.dart';
import '../controller/MultiplayerQuizController.dart';
import 'ViewResultsScreen.dart';
import '../utils/roomdeletion_utils.dart'; // Import the room deletion utils for the dialog

class MultiplayerQuizScreen extends StatefulWidget {
  final String roomId;
  final String category; // Category passed from the room
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    // Load all questions from the CSV
    final allQuestions = await controller.loadQuestions();

    // Filter questions based on the category and limit to the first 5
    final filteredQuestions = allQuestions
        .where((question) =>
    question['category'].toString().trim() == widget.category.trim())
        .toList()
        .take(5)
        .toList(); // Limit to 5 questions

    setState(() {
      _questions = filteredQuestions;
      _isLoading = false;
    });
  }

  void _submitAnswer() async {
    if (_selectedAnswer == null) return;

    String correctAnswer = _questions[_currentQuestionIndex]['correctAnswer'];
    setState(() {
      _correctAnswer = correctAnswer;
    });

    // Check if the answer is correct
    if (_selectedAnswer == correctAnswer) {
      setState(() {
        _roomPoints += 5; // Add points to the UI immediately
      });

      // Update points asynchronously without blocking the UI
      controller.updateRoomPoints(widget.roomId, widget.userEmail).catchError((error) {
        print('Error updating room points: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update room points. Please try again.')),
        );
      });

      controller.updateUserPoints(widget.userEmail).catchError((error) {
        print('Error updating user points: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user points. Please try again.')),
        );
      });
    }

    // Move to the next question immediately
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null; // Reset selected answer for the next question
      });
    } else {
      setState(() {
        _isQuizCompleted = true;
      });
    }
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

  Future<bool> _onWillPop() async {
    // Show dialog to confirm if the user wants to leave the room
    await showLeaveRoomDialog(
      context: context,
      userEmail: widget.userEmail,
      roomId: widget.roomId, email: '', userName: '',
    );

    return Future.value(false); // Prevent default back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Override back button action
      child: Scaffold(
        appBar: AppBar(
          title: Text("Quiz"),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _questions.isEmpty
            ? Center(child: Text('No questions available for this category.'))
            : Column(
          children: [
            if (_isQuizCompleted)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewResultsScreen(
                          roomId: widget.roomId,
                          userEmail: widget.userEmail, userName: '',),
                    ),
                  );
                },
                child: Text('View Results'),
              )
            else ...[
              Text("Question ${_currentQuestionIndex + 1}/${_questions.length}"),
              SizedBox(height: 20),
              Text(
                _questions[_currentQuestionIndex]['question'],
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectedAnswer == null ? null : _submitAnswer,
                child: Text("Next"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
