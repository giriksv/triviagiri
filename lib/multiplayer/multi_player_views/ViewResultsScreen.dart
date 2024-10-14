import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/background_color_utils.dart';
import '../../utils/custom_app_bar.dart';
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
        appBar: customAppBar(), // Use the custom AppBar
        backgroundColor: BackgroundColorUtils.backgroundColor,
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz Results', // Added heading
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0), // Space between heading and list
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var user = users[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white, width: 4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: index % 2 == 0 ? Color(0xFFD7EAF8) : Color(0xFFFAE5D2), // Alternate card background colors
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Circular Avatar with number
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFEF1212), // Background color of avatar
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}', // Displaying index + 1 for numbering
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.0), // Space between avatar and user name
                                Expanded(
                                  child: Text(
                                    user['name'], // Display user name
                                    style: TextStyle(fontWeight: FontWeight.bold), // Bold text for user name
                                  ),
                                ),
                                SizedBox(width: 16.0), // Space between name and points
                                Text(
                                  '${user['roomPoints']}', // Only the points number displayed
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Color(0xFF4C2F54), // Color for points
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
