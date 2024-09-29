import 'package:flutter/material.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import 'notification_screen.dart'; // Import the NotificationScreen

class RoomTypeScreen extends StatelessWidget {
  final String email;
  final int maxUsers;

  RoomTypeScreen({required this.email, this.maxUsers = 2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Multiplayer Options"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to the NotificationScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(email: email),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose Your Multiplayer Option:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateRoomScreen(
                      email: email,
                      maxUsers: maxUsers,
                    ),
                  ),
                );
              },
              child: Text("Create Room"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinRoomScreen(
                      email: email,
                      maxUsers: maxUsers,
                    ),
                  ),
                );
              },
              child: Text("Join Room"),
            ),
          ],
        ),
      ),
    );
  }
}