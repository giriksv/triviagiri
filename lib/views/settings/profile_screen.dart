import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../utils/custom_app_bar.dart';
import '../../utils/gifutils.dart';
import 'CategoryPointsScreen.dart';
import '../signup_screen.dart';
import '../../utils/background_color_utils.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String selectedCharacter; // Add selectedCharacter
  final int points; // Add points

  ProfileScreen({
    required this.name,
    required this.email,
    required this.selectedCharacter, // Include in constructor
    required this.points, // Include in constructor
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Use the getCharacterGif method from gifutils.dart
    String? gifPath = CharacterUtils.getCharacterGif(widget.selectedCharacter);

    return Scaffold(
      appBar: customAppBar(
        showBackButton: true,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: BackgroundColorUtils.backgroundColor, // Use your utility for background color
      body: SingleChildScrollView( // Wrap the content in SingleChildScrollView
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the character's GIF in 150x150 size
              SizedBox(
                width: 150,
                height: 150,
                child: gifPath != null
                    ? Image.asset(gifPath)
                    : Icon(Icons.person, size: 150), // Fallback if GIF not found
              ),
              SizedBox(height: 20),
              Text(
                widget.name, // Display name in bold and black color
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.selectedCharacter, // Display selected character
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              // Points display with a green background and larger size
              GestureDetector(
                onTap: () {
                  // Navigate to CategoryPointsScreen on tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPointsScreen(
                        userEmail: widget.email, // Pass the user email
                        userName: widget.name, // Pass the user name if needed
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(15), // Increased padding for larger size
                  decoration: BoxDecoration(
                    color: Colors.green, // Green background
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white, // White border color
                      width: 4, // Border width of 4 pixels
                    ),
                  ),
                  child: Text(
                    'Total Points: ${widget.points}', // Display points
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white, // Adjust text color
                      fontWeight: FontWeight.bold, // Set font weight to bold
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Logout button with slightly curved edges and white text
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDE6786), // Custom background color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Increased padding for larger size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Slightly curved edges
                  ),
                ),
                onPressed: () async {
                  // Show a confirmation dialog before logging out
                  final bool? shouldLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Logout'),
                        content: Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldLogout == true) {
                    // Proceed with signing out
                    await _googleSignIn.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                          (route) => false, // Remove all previous routes
                    );
                  }
                },
                child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.white), // Set text color to white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
