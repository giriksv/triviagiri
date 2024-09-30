import 'package:flutter/material.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import 'notification_screen.dart';
import '../multi_player_model/notification_model.dart';

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
          StreamBuilder<List<NotificationData>>(
            stream: NotificationModel(email: email).getNotifications(),
            builder: (context, snapshot) {
              // Check if there's an error in loading notifications
              if (snapshot.hasError) {
                return IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(email: email),
                      ),
                    );
                  },
                );
              }

              // Check the connection state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return IconButton(
                  icon: CircularProgressIndicator(),
                  onPressed: null,
                );
              }

              // Get notifications
              var notifications = snapshot.data ?? [];
              bool hasNotifications = notifications.isNotEmpty;
              bool allViewed = notifications.every((notification) => notification.viewed); // Check if all notifications are viewed

              return IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: hasNotifications && !allViewed ? Colors.red : Colors.black, // Change icon color logic
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(email: email),
                    ),
                  );
                },
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
