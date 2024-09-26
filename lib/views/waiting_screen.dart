import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'multiplayer_quiz_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaitingScreen extends StatefulWidget {
  final String roomName;
  final String roomId;
  final List members;
  final int maxUsers;

  WaitingScreen({
    required this.roomName,
    required this.roomId,
    required this.members,
    required this.maxUsers,
  });

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late Timer _checkRoomTimer;
  late Timer _countdownTimer;
  int _countdown = 10;
  bool _isRoomFull = false;
  String userEmail = ''; // Variable to hold the user email

  @override
  void initState() {
    super.initState();
    _getUserEmail(); // Get the user email when the screen initializes
    _checkRoomStatus();
  }

  Future<void> _getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email ?? '';
    });
    print("User Email: $userEmail");
  }

  Future<void> _checkRoomStatus() async {
    _checkRoomTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      DocumentSnapshot roomSnapshot =
      await FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).get();
      List currentUsers = roomSnapshot['users'];

      print("Current users in the room: ${currentUsers.length}");
      if (currentUsers.length >= widget.maxUsers) {
        timer.cancel();
        _startCountdown();
      }
    });
  }

  void _startCountdown() {
    setState(() {
      _isRoomFull = true;
    });

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        // Navigate to the MultiplayerQuizScreen with proper parameters
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiplayerQuizScreen(
              roomId: widget.roomId,
              category: '', // Replace with actual category if available
              userEmail: userEmail, // Use the user email obtained
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Waiting for Players"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Room: ${widget.roomName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Room ID: ${widget.roomId}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Waiting for players to join...',
              style: TextStyle(fontSize: 20),
            ),
            ...widget.members.map((member) => Text(member['name'])).toList(),
            SizedBox(height: 20),
            if (_isRoomFull)
              Text(
                'Game begins in $_countdown seconds...',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _checkRoomTimer.cancel();
    _countdownTimer.cancel();
    super.dispose();
  }
}
