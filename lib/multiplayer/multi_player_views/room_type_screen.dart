import 'package:flutter/material.dart';
import '../../utils/background_color_utils.dart';
import '../../utils/custom_app_bar.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import 'notification_screen.dart';
import '../multi_player_model/notification_model.dart';

class RoomTypeScreen extends StatelessWidget {
  final String email;  // Accepting the email passed from ModeSelectionScreen
  final int maxUsers;

  RoomTypeScreen({required this.email, this.maxUsers = 2});

  @override
  Widget build(BuildContext context) {
    print('RoomTypeScreen: build called'); // Debug statement

    return Scaffold(
      appBar: customAppBar(),  // Use the custom AppBar
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
            SizedBox(height: 20),

            // Notification icon
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
                  return CircularProgressIndicator();
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

            SizedBox(height: 40),
            _buildActionButton(
              context,
              label: 'Create Room',
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
            ),
            SizedBox(height: 20),
            _buildActionButton(
              context,
              label: 'Join Room',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFFE76A89),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
