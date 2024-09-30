// notification_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notification_model.dart';
import 'waiting_screen.dart';

class NotificationController {
  final String email;

  NotificationController({required this.email});

  Future<void> joinRoom(BuildContext context, String roomId, String userName, String notificationId) async {
    try {
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

      await roomRef.update({
        'users': FieldValue.arrayUnion([
          {
            'email': email,
            'name': userName,
            'roomPoints': 0,
          }
        ]),
        'invitedUsers': FieldValue.arrayRemove([email]),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingScreen(
            roomName: roomData['roomName'] ?? 'Unknown',
            roomId: roomId,
            maxUsers: maxUsers,
            email: email,
            members: [],
          ),
        ),
      );

      await NotificationModel(email: email).deleteNotification(notificationId);
    } catch (e) {
      print('Error joining room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join room')),
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await NotificationModel(email: email).deleteNotification(notificationId);
  }
}
