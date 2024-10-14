import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../utils/background_color_utils.dart';
import '../../utils/custom_app_bar.dart';
import '../../utils/roomdeletion_utils.dart'; // Import your room deletion utilities
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
    required this.maxUsers,
    required String email,
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
        await showLeaveRoomDialog(
          context: context,
          userEmail: userEmail,
          roomId: widget.roomId,
          email: userEmail,
          userName: '',
        );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: customAppBar(), // Use the custom AppBar
        backgroundColor: BackgroundColorUtils.backgroundColor,
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
              child: SingleChildScrollView(
                child: Container(
                  width: 300, // Reduced width for the main white container
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0), // Curved edges
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Room information
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFEDEC), // #FFEDEC background color
                          borderRadius: BorderRadius.circular(15.0), // Curved edges
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Room: ${widget.roomName}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Room ID: ${widget.roomId}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Category: ${category ?? "Not specified"}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Room Size: ${widget.maxUsers}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Waiting details, GIF, and Send Invite button
                      if (membersNeeded > 0)
                        Text(
                          'Waiting for $membersNeeded more players to join',
                          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.blue),
                        ),
                      SizedBox(height: 20),

                      // User List with Circular Avatars
                      Column(
                        children: currentUsers.map((user) {
                          String name = user['name'];
                          String firstLetter = name.isNotEmpty ? name[0] : '?'; // Handle empty names

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF98D9F), // Background color for avatar
                                  ),
                                  child: Center(
                                    child: Text(
                                      firstLetter.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10), // Spacing between avatar and name
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      if (_isRoomFull)
                        Text(
                          'Game begins in $_countdown seconds...',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      SizedBox(height: 20),

                      // GIF
                      Center(
                        child: Container(
                          width: 100, // Adjust width as needed
                          height: 100, // Adjust height as needed
                          child: Image.asset('assets/gif/waitingscreen.gif'), // Ensure the path is correct
                        ),
                      ),
                      SizedBox(height: 20),

                      // Send Invite button
                      ElevatedButton(
                        onPressed: () {
                          _openInviteDialog(invitedUsers);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Green background color
                        ),
                        child: Text(
                          'Send Invite',
                          style: TextStyle(color: Colors.white), // White text color
                        ),
                      ),
                    ],
                  ),
                ),
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
