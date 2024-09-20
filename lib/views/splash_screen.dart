import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/db_controller.dart';
import '../model/quiz_model.dart';
import '../services/storage_service.dart';
import 'category_screen.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DBController _dbController = DBController();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Perform background operations
    await _fetchAndStoreQuizzes();

    // Wait for at least 3 seconds before navigating
    await Future.delayed(Duration(seconds: 3));

    // Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, navigate to the CategoryScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CategoryScreen()),
      );
    } else {
      // User is not logged in, navigate to SignUpScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignupScreen()),
      );
    }
  }

  Future<void> _fetchAndStoreQuizzes() async {
    try {
      // Fetch quizzes from Firestore and store them in the local database
      List<QuizModel> quizzes = await _storageService.fetchCsvFromStorage('quizcsvfirestorage.csv');
      await _dbController.clearAndCreateDb(quizzes);
    } catch (e) {
      print('Error fetching quizzes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loading indicator
      ),
    );
  }
}
