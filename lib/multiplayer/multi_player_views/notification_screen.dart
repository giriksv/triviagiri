// notification_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../multi_player_model/notification_model.dart';
import '../multi_player_controller/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  final String email;
  final NotificationController controller;

  NotificationScreen({required this.email}) : controller = NotificationController(email: email);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<List<NotificationData>>(
        stream: NotificationModel(email: email).getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(child: Text('No notifications'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              if (notification.type == 'invite') {
                return Card(
                  child: ListTile(
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: formatTimestamp(notification.timestamp), // Formatted timestamp
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '\n${notification.senderName} has invited you to join their room',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text('Room ID: ${notification.roomId}\nCategory: ${notification.category}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Fetch user's name
                            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(email).get();
                            String userName = userSnapshot['name'] ?? 'Unknown';

                            await controller.joinRoom(context, notification.roomId, userName, notification.id);
                          },
                          child: Text('Join'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await controller.deleteNotification(notification.id);
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
                return SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime notificationTime = timestamp.toDate();
    DateTime now = DateTime.now();

    if (now.year == notificationTime.year && now.month == notificationTime.month && now.day == notificationTime.day) {
      return 'Today ${_formatTime(notificationTime)}';
    } else if (now.year == notificationTime.year && now.month == notificationTime.month && now.day == notificationTime.day - 1) {
      return 'Yesterday ${_formatTime(notificationTime)}';
    } else {
      return '${_formatDate(notificationTime)} - ${_formatTime(notificationTime)}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}