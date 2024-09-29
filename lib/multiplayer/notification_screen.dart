// notification_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'waiting_screen.dart';

class NotificationScreen extends StatelessWidget {
  final String email;

  NotificationScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(email)
            .collection('userNotifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return Center(child: Text('No notifications'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index].data() as Map<String, dynamic>;
              String type = notification['type'] ?? '';
              if (type == 'invite') {
                String senderName = notification['senderName'] ?? 'Unknown';
                String roomId = notification['roomId'] ?? '';
                String category = notification['category'] ?? 'Unknown';

                return Card(
                  child: ListTile(
                    title: Text('$senderName has invited you to a room'),
                    subtitle: Text('Room ID: $roomId\nCategory: $category'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await _joinRoom(context, roomId);
                            await _deleteNotification(notifications[index].id);
                          },
                          child: Text('Join'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await _deleteNotification(notifications[index].id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Handle other notification types if any
                return SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }

  // Handle joining a room
  Future<void> _joinRoom(BuildContext context, String roomId) async {
    try {
      // Get the room document
      DocumentReference roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
      DocumentSnapshot roomSnapshot = await roomRef.get();

      if (!roomSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room does not exist')),
        );
        return;
      }

      var roomData = roomSnapshot.data() as Map<String, dynamic>;
      List<dynamic> users = roomData['users'] ?? [];
      int maxUsers = roomData['maxUsers'] ?? 2;

      if (users.length >= maxUsers) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room is full')),
        );
        return;
      }

      // Fetch the user's name from 'users' collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      String userName = userSnapshot['name'] ?? 'Unknown';

      // Add the current user to the room's users array
      await roomRef.update({
        'users': FieldValue.arrayUnion([
          {
            'email': email,
            'name': userName,
            'roomPoints': 0,
          }
        ]),
        // Optionally, remove from invitedUsers
        'invitedUsers': FieldValue.arrayRemove([email]),
      });

      // Navigate to the WaitingScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingScreen(
            roomName: roomData['roomName'] ?? 'Unknown',
            roomId: roomId,
            maxUsers: maxUsers,
            email: email, members: [],
          ),
        ),
      );
    } catch (e) {
      print('Error joining room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join room')),
      );
    }
  }

  // Handle deleting a notification
  Future<void> _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(email)
          .collection('userNotifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
