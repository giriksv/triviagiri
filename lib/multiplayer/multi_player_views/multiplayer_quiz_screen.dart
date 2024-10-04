import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/background_color_utils.dart';
import '../../utils/custom_app_bar.dart';
import '../multi_player_controller/MultiplayerQuizController.dart';
import 'ViewResultsScreen.dart';
import '../../utils/roomdeletion_utils.dart';

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
  bool _isLoading = false;

  Timer? _timer;
  int _remainingTime = 7;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    final allQuestions = await controller.loadQuestions();
    final filteredQuestions = allQuestions
        .where((question) => question['category'].toString().trim() == widget.category.trim())
        .toList()
        .take(5)
        .toList();

    setState(() {
      _questions = filteredQuestions;
      _isLoading = false;
    });

    _startTimer();
  }

  void _startTimer() {
    _remainingTime = 7;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _autoSubmitAnswer();
        }
      });
    });
  }

  void _autoSubmitAnswer() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _correctAnswer = null;
      });
      _startTimer();
    } else {
      setState(() {
        _isQuizCompleted = true;
      });
    }
  }

  void _submitAnswer() async {
    if (_selectedAnswer == null) return;

    String correctAnswer = _questions[_currentQuestionIndex]['correctAnswer'];
    setState(() {
      _correctAnswer = correctAnswer;
    });

    if (_selectedAnswer == correctAnswer) {
      setState(() {
        _roomPoints += 5;
      });

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

    _timer?.cancel();

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _correctAnswer = null;
      });
      _startTimer();
    } else {
      setState(() {
        _isQuizCompleted = true;
      });
    }
  }

  Widget _buildOptionButton(String optionText, String optionValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedAnswer = optionValue;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedAnswer == optionValue
              ? Colors.green.shade300
              : Color(0xFFFA7B95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Text(
          optionText,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    await showLeaveRoomDialog(
      context: context,
      userEmail: widget.userEmail,
      roomId: widget.roomId,
      email: '',
      userName: '',
    );

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: customAppBar(),
        backgroundColor: BackgroundColorUtils.backgroundColor,
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _questions.isEmpty
            ? Center(child: Text('No questions available for this category.'))
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quiz: ${_currentQuestionIndex + 1}/${_questions.length}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Time: $_remainingTime s",
                      style: TextStyle(fontSize: 18, color: Color(0xFFC85E7E)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (_isQuizCompleted)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewResultsScreen(
                            roomId: widget.roomId,
                            userEmail: widget.userEmail,
                            userName: '',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    ),
                    child: Text(
                      'View Results',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                else ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFFFA7B95), width: 4),
                    ),
                    child: Text(
                      _questions[_currentQuestionIndex]['question'],
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      _buildOptionButton(_questions[_currentQuestionIndex]['optionA'], _questions[_currentQuestionIndex]['optionA']),
                      _buildOptionButton(_questions[_currentQuestionIndex]['optionB'], _questions[_currentQuestionIndex]['optionB']),
                      _buildOptionButton(_questions[_currentQuestionIndex]['optionC'], _questions[_currentQuestionIndex]['optionC']),
                      _buildOptionButton(_questions[_currentQuestionIndex]['optionD'], _questions[_currentQuestionIndex]['optionD']),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.08,
                    child: ElevatedButton(
                      onPressed: _selectedAnswer == null ? null : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF01CCCA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
