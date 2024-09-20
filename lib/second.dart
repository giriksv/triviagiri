import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'views/signup_screen.dart';

class second extends StatefulWidget {
  final String url;
  final String name;
  final String email;

  second({
    required this.url,
    required this.name,
    required this.email,
  });

  @override
  _secondState createState() => _secondState();
}

class _secondState extends State<second> {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _storeUserEmail(widget.email);
  }

  void _storeUserEmail(String email) async {
    try {
      // Check if the user already exists
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(email).get();

      if (!userDoc.exists) {
        // If not, create a new document for the user
        await _firestore.collection('users').doc(email).set({
          'email': email,
          'name': widget.name,
          'url': widget.url,
        });
      }
    } catch (e) {
      print('Error storing user email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Zeal ',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            Text(
              'Town',
              style: TextStyle(
                color: Colors.yellow[700],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.url),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(height: 20),
            Text(
              widget.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            TextButton(
              onPressed: () async {
                try {
                  await _googleSignIn.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupScreen(),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
