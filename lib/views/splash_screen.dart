import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/all_db_controller.dart';
import '../model/single_player_quiz_model.dart';
import '../services/storage_service.dart';
import 'modeselection_screen.dart';
import 'signup_screen.dart';
import '../controller/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AllDBController _dbController = AllDBController();
  final StorageService _storageService = StorageService();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _startBackgroundTasks();
    _navigateAfterDelay();
  }

  // Function to run background tasks like CSV fetching and authentication
  void _startBackgroundTasks() {
    Future.microtask(() async {
      await _fetchAndStoreQuizzes();
      await _authenticateUser();
    });
  }

  // This ensures that the app navigates after 3 seconds
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(Duration(seconds: 3));
    _navigateToNextScreen();
  }

  Future<void> _fetchAndStoreQuizzes() async {
    try {
      List<QuizModel> quizzes =
      await _storageService.fetchCsvFromStorage('quizcsvfirestorage.csv');
      await _dbController.clearAndCreateDb(quizzes);
    } catch (e) {
      print('Error fetching quizzes: $e');
    }
  }

  Future<void> _authenticateUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await _authController.refreshGoogleSignInToken();
    }
  }

  void _navigateToNextScreen() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ModeSelectionScreen(email: user.email!)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF04143C),  // #04143C
              Color(0xFFFB7290),  // #FB7290
              Color(0xFFF7C6BF),  // #F7C6BF
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Trivia',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, -2),
                      color: Color(0xFF583458),  // Text border color (#583458)
                    ),
                  ],
                  decoration: TextDecoration.none,
                  decorationColor: Color(0xFF583458),  // Border color for text
                  decorationThickness: 1.5,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white54,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Loading, please wait...',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
