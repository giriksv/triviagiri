import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../utils/roomdeletion_utils.dart'; // Import your room deletion utilities
import 'multiplayer_quiz_screen.dart';
import 'notification_screen.dart';
import 'invite_dialog.dart';

class WaitingScreen extends StatefulWidget {
  final String roomName;
  final String roomId;
  final List members;
  final int maxUsers;

  WaitingScreen({
    required this.roomName,
    required this.roomId,
    required this.members,
    required this.maxUsers, required String email,
  });

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late Timer _countdownTimer;
  int _countdown = 10;
  bool _isRoomFull = false;
  String userEmail = '';
  String? category; // Store the category from Firestore

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email ?? '';
    });
  }

  void _startCountdown() {
    if (_isRoomFull) return; // Prevent multiple countdowns

    setState(() {
      _isRoomFull = true; // Indicate the room is full
    });

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiplayerQuizScreen(
              roomId: widget.roomId,
              category: category ?? '', // Use the fetched category
              userEmail: userEmail,
            ),
          ),
        );
      }
    });
  }

  void _checkRoomFull(List<dynamic> currentUsers) {
    if (currentUsers.length >= widget.maxUsers && !_isRoomFull) {
      // Delay the countdown to avoid setState() in the middle of the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startCountdown();
      });
    }
  }

  void _openInviteDialog(List<dynamic> invitedUsers) {
    showDialog(
      context: context,
      builder: (context) {
        return InviteDialog(
          roomId: widget.roomId,
          category: category ?? 'Unknown',
          email: userEmail,
          invitedUsers: List<String>.from(invitedUsers),
          currentMembersEmails: widget.members.map((m) => m['email'] as String).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show the leave room dialog when back is pressed
        await showLeaveRoomDialog(
          context: context,
          userEmail: userEmail,
          roomId: widget.roomId,
          email: userEmail,
          userName: '', // Use the email of the current user
        );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Waiting for Players"),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Navigate to the NotificationScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(email: userEmail),
                  ),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomId)
              .snapshots(), // Listen to real-time updates in the room document
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading room data'));
            }

            var roomData = snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> currentUsers = roomData['users'];
            List<dynamic> invitedUsers = roomData['invitedUsers'] ?? [];

            // Fetch the category from the room document
            category = roomData['category'];

            // Check if the room is full
            _checkRoomFull(currentUsers);

            // Calculate the number of members needed
            int membersNeeded = widget.maxUsers - currentUsers.length;

            return Center(
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
                    'Category: ${category ?? "Not specified"}', // Show category
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Room Size: ${widget.maxUsers}', // Show max users
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  if (membersNeeded > 0)
                    Text(
                      'Waiting for $membersNeeded more players to join',
                      style: TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                  SizedBox(height: 20),
                  Text(
                    'Waiting for players to join...',
                    style: TextStyle(fontSize: 20),
                  ),
                  ...currentUsers.map((user) => Text(user['name'])).toList(),
                  SizedBox(height: 20),
                  if (_isRoomFull)
                    Text(
                      'Game begins in $_countdown seconds...',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _openInviteDialog(invitedUsers);
                    },
                    child: Text('Send Invite'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // Ensure the timer is cancelled
    super.dispose();
  }
}