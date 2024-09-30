import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/all_db_controller.dart';
import '../model/single_player_quiz_model.dart';
import '../services/storage_service.dart';
import 'category_screen.dart';
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
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
