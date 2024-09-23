import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signup_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              // Add image if available: backgroundImage: NetworkImage(widget.url),
            ),
            SizedBox(height: 20),
            Text(
              'Name: ${widget.name}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Email: ${widget.email}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Selected Character: ${widget.selectedCharacter}', // Display selected character
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Points: ${widget.points}', // Display points
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _googleSignIn.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                      (route) => false, // Remove all previous routes
                );
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
