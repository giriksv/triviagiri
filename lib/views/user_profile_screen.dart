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
  String? _myName;
  String? _myCharacter;
  int? _myPoints;

  String? _otherUserName;
  String? _otherUserCharacter;
  int? _otherUserPoints;

  @override
  void initState() {
    super.initState();
    _fetchMyDetails();
    _fetchOtherUserDetails(widget.otherUserEmail);
  }

  Future<void> _fetchMyDetails() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    print("Fetching my details for: $userEmail");
    if (userEmail != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userEmail).get();
        if (userDoc.exists) {
          setState(() {
            _myName = userDoc['name'] ?? "Not Available";
            _myCharacter = userDoc['selectedCharacter'] ?? "Not Available"; // Update here
            _myPoints = userDoc['points'] ?? 0;
          });
        } else {
          print("My user not found!");
        }
      } catch (e) {
        print("Error fetching my details: $e");
      }
    }
  }

  Future<void> _fetchOtherUserDetails(String email) async {
    print("Fetching other user details for: $email");
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
      if (userDoc.exists) {
        setState(() {
          _otherUserName = userDoc['name'] ?? "Not Available";
          _otherUserCharacter = userDoc['selectedCharacter'] ?? "Not Available"; // Update here
          _otherUserPoints = userDoc['points'] ?? 0;
        });
      } else {
        print("Other user not found!");
      }
    } catch (e) {
      print("Error fetching other user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Name: ${_myName ?? "Loading..."}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('My Character: ${_myCharacter ?? "Loading..."}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('My Points: ${_myPoints?.toString() ?? "Loading..."}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text('Other Name: ${_otherUserName ?? "Loading..."}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Other Character: ${_otherUserCharacter ?? "Loading..."}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Other Points: ${_otherUserPoints?.toString() ?? "Loading..."}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
