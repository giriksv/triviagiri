import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  final String otherUserEmail;

  UserProfileScreen({required this.otherUserEmail});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // StreamBuilder for my user details
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading my details...');
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('My user not found!');
                }

                final userData = snapshot.data!;
                final myName = userData['name'] ?? "Not Available";
                final myCharacter = userData['selectedCharacter'] ?? "Not Available";
                final myPoints = userData['points'] ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Name: $myName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('My Character: $myCharacter', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('My Points: $myPoints', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),

            // StreamBuilder for other user details
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.otherUserEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading other user details...');
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('Other user not found!');
                }

                final userData = snapshot.data!;
                final otherUserName = userData['name'] ?? "Not Available";
                final otherUserCharacter = userData['selectedCharacter'] ?? "Not Available";
                final otherUserPoints = userData['points'] ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Other Name: $otherUserName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Other Character: $otherUserCharacter', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('Other Points: $otherUserPoints', style: TextStyle(fontSize: 18)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
