import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/roomdeletion_utils.dart'; // Import the room deletion utility

class ViewResultsScreen extends StatelessWidget {
  final String roomId;
  final String userName;
  final String userEmail;

  ViewResultsScreen({
    required this.roomId,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Call the showLeaveRoomDialog from the roomdeletion_utils
        await showLeaveRoomDialog(
          context: context,
          userEmail: userEmail,
          roomId: roomId,
          userName: userName,
          email: userEmail, // Ensure correct params
        );
        return false; // Prevent default back navigation until confirmed
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Quiz Results"),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc(roomId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            var roomData = snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> users = roomData['users'];

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return ListTile(
                  title: Text(user['name']), // Display user name
                  subtitle: Text('Points: ${user['roomPoints']}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
