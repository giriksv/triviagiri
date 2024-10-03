import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/gifutils.dart';

class ComparisonScreen extends StatefulWidget {
  final String otherUserEmail;

  ComparisonScreen({required this.otherUserEmail});

  @override
  _ComparisonScreenState createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile Comparison'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // My user details
                  Flexible(
                    child: _buildUserSection(userEmail, true),
                  ),

                  // The GIF in between two profiles
                  Container(
                    width: 100, // Constrain the width as needed
                    height: 100, // Adjust the height as needed
                    child: Image.asset('assets/gif/vs.gif'),
                  ),

                  // Other user details
                  Flexible(
                    child: _buildUserSection(widget.otherUserEmail, false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(String? email, bool isCurrentUser) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(email).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('User not found!',
              style: TextStyle(fontSize: 18, color: Colors.red));
        }

        final userData = snapshot.data!;
        final userName = userData['name'] ?? "Not Available";
        final userCharacter = userData['selectedCharacter'] ?? "Not Available";
        final userPoints = userData['points'] ?? 0;

        // Get the GIF path using CharacterUtils
        final gifPath = CharacterUtils.getCharacterGif(userCharacter);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the character's GIF or fallback if not found
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: gifPath != null
                  ? Image.asset(gifPath)
                  : Icon(Icons.person, size: 50), // Fallback icon
            ),
            SizedBox(height: 10),
            Text(userName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Character: $userCharacter', style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text('Points: $userPoints', style: TextStyle(fontSize: 16)),
          ],
        );
      },
    );
  }
}
