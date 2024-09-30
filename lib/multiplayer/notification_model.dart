// notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String email;

  NotificationModel({required this.email});

  Stream<List<NotificationData>> getNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(email)
        .collection('userNotifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return NotificationData.fromSnapshot(doc);
    }).toList());
  }

  Future<void> deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(email)
        .collection('userNotifications')
        .doc(notificationId)
        .delete();
  }
}

class NotificationData {
  final String id;
  final String type;
  final String senderName;
  final String roomId;
  final String category;
  final Timestamp timestamp;

  NotificationData({
    required this.id,
    required this.type,
    required this.senderName,
    required this.roomId,
    required this.category,
    required this.timestamp,
  });

  factory NotificationData.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationData(
      id: doc.id,
      type: data['type'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      roomId: data['roomId'] ?? '',
      category: data['category'] ?? 'Unknown',
      timestamp: data['timestamp'],
    );
  }
}
