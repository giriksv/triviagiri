import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'character_selection.dart';

class SignupScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        try {
          UserCredential userCredential = await _auth.signInWithCredential(credential);
          User? user = userCredential.user;

          // Only store the email if user is not already in Firestore
          if (user != null) {
            // Navigate to Character Selection Screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CharacterSelectionScreen(email: user.email ?? '')),
            );
          }
        } catch (e) {
          // Handle error
          print("Error signing in with Google: $e");
        }
      }
    } else {
      print("Google sign-in was canceled.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await signInWithGoogle(context);
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
