import 'package:flutter/material.dart';
import '../../utils/background_color_utils.dart';
import '../../utils/custom_app_bar.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';

class RoomTypeScreen extends StatelessWidget {
  final String email;  // Accepting the email passed from ModeSelectionScreen
  final int maxUsers;

  RoomTypeScreen({required this.email, this.maxUsers = 2});

  @override
  Widget build(BuildContext context) {
    print('RoomTypeScreen: build called'); // Debug statement

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Color(0xFF04143C),
              Color(0xFFFB7290),
              Color(0xFFF7C6BF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            'Trivia',
            style: TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.75,
              height: 68.84 / 54,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  color: Colors.black,
                  blurRadius: 5.0,
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFFEDEC),
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            print('Back button pressed'); // Debug statement
            Navigator.pop(context, email);  // Passing email back when popping
          },
        ),
      ),
      backgroundColor: BackgroundColorUtils.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Choose Your\nMultiplayer Option:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFFE76A89),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                print('Navigating to CreateRoomScreen'); // Debug statement
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateRoomScreen(
                      email: email, // Passing email forward to CreateRoomScreen
                      maxUsers: maxUsers,
                    ),
                  ),
                );
              },
              child: Text(
                'Create Room',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFFE76A89),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                print('Navigating to JoinRoomScreen'); // Debug statement
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinRoomScreen(
                      email: email, // Passing email forward to JoinRoomScreen
                      maxUsers: maxUsers,
                    ),
                  ),
                );
              },
              child: Text(
                'Join Room',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
