import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../controller/all_db_controller.dart';
import '../model/user_model.dart';
import 'character_selection.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController _authController = AuthController();
  final AllDBController _dbController = AllDBController();
  bool _isLoading = false;

  Future<void> signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Sign in with Google and get user details
      UserModel? user = await _authController.signInWithGoogle();

      if (user != null) {
        // Store user data in Firestore
        await _dbController.insertUserData(user);

        print("User signed in: ${user.email}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterSelectionScreen(
              email: user.email,
              name: user.name,
              points: 20,// Pass the name here
            ),
          ),
        );
      } else {
        throw Exception("Error: User not signed in.");
      }
    } catch (e) {
      print("Error during sign-in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing in: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await signInWithGoogle(context);
                    },
                    child: Text('Continue with Google'),
                  ),
                ],
              ),
      ),
    );
  }
}
