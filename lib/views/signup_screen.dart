import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../controller/all_db_controller.dart';
import '../model/user_model.dart';
import 'character_selection.dart';
import '../utils/custom_app_bar.dart';  // Import the custom AppBar
import '../utils/background_color_utils.dart'; // Import the background color utils

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
      UserModel? user = await _authController.signInWithGoogle();

      if (user != null) {
        await _dbController.insertUserData(user);

        print("User signed in: ${user.email}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterSelectionScreen(
              email: user.email,
              name: user.name,
              points: 20, // Pass the points here
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
      appBar: customAppBar(),  // Use the custom AppBar
      body: Container(
        width: double.infinity, // Ensures the container stretches to fill the width
        height: double.infinity, // Ensures the container stretches to fill the height
        color: BackgroundColorUtils.backgroundColor, // Set the background color
        child: SingleChildScrollView(  // Make the body scrollable
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 200), // Space from the app bar
                  Text(
                    'Hello..!',
                    style: TextStyle(
                      color: Colors.black, // Set text color to white
                      fontSize: MediaQuery.of(context).size.width * 0.08, // Responsive font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50), // Space between text and button
                  Text(
                    'Create your account and continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7D7E80), // Set text color to #7D7E80
                      fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
                    ),
                  ),
                  SizedBox(height: 50), // Space before the button
                  _isLoading
                      ? CircularProgressIndicator() // Show loading indicator
                      : SizedBox(
                    width: double.infinity, // Make the button full-width
                    child: ElevatedButton(
                      onPressed: () async {
                        await signInWithGoogle(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDE6786), // Set the button color
                        padding: EdgeInsets.symmetric(vertical: 15), // Increase vertical padding
                      ),
                      child: Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Colors.white, // Set button text color to white
                          fontSize: MediaQuery.of(context).size.width * 0.045, // Responsive font size
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Space after button
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Extra space for smaller screens
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
