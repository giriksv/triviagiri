import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // For date formatting
import '../../utils/background_color_utils.dart';
import '../../utils/custom_app_bar.dart';
import '../multi_player_model/notification_model.dart';
import '../multi_player_controller/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  final String email;
  final NotificationController controller;

  NotificationScreen({required this.email}) : controller = NotificationController(email: email);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(),
      backgroundColor: BackgroundColorUtils.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),  // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<NotificationData>>(
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
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shadowColor: Color(0x40000000),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),  // Responsive padding inside card
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.pink,
                                      child: Text(
                                        notification.senderName[0],
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${notification.senderName} has invited you to join their room\n',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                                fontSize: 16,
                                                height: 1.5,  // Add spacing between lines
                                              ),
                                            ),
                                            WidgetSpan(
                                              child: SizedBox(height: 8),  // Add spacing between the lines
                                            ),
                                            TextSpan(
                                              text: 'Room Id: ${notification.roomId}\nCategory: ${notification.category}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 14,
                                                height: 1.5,  // Add spacing between lines
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _getFormattedTimestamp(notification.timestamp),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(email).get();
                                          String userName = userSnapshot['name'] ?? 'Unknown';

                                          await controller.joinRoom(context, notification.roomId, userName, notification.id);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF349D0F),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.1,
                                            vertical: screenWidth * 0.03,
                                          ),  // Responsive button padding
                                        ),
                                        child: Text(
                                          'Join',
                                          style: TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.04),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await controller.deleteNotification(notification.id);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFEF1212),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.1,
                                            vertical: screenWidth * 0.03,
                                          ),  // Responsive button padding
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  // Method to format the timestamp
  String _getFormattedTimestamp(Timestamp timestamp) {
    DateTime notificationTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(notificationTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    }

    if (now.year == notificationTime.year &&
        now.month == notificationTime.month &&
        now.day == notificationTime.day) {
      return 'Today ${_formatTime(notificationTime)}';
    }

    if (now.year == notificationTime.year &&
        now.month == notificationTime.month &&
        now.day == notificationTime.day - 1) {
      return 'Yesterday ${_formatTime(notificationTime)}';
    }

    return '${_formatDate(notificationTime)} - ${_formatTime(notificationTime)}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }
}
