import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/splash_screen.dart'; // Import SplashScreen

Future<void> removeUserAndHandleRoomDeletion({
  required BuildContext context,
  required String userEmail,
  required String roomId,
}) async {
  DocumentReference roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);

  // Run a Firestore transaction to safely handle the update
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentSnapshot roomSnapshot = await transaction.get(roomRef);

    if (roomSnapshot.exists) {
      List<dynamic> users = List.from(roomSnapshot['users']); // Create a mutable copy of users

      // Remove the user from the users array
      users.removeWhere((user) => user['email'] == userEmail);

      // If the users array is empty, delete the room
      if (users.isEmpty) {
        transaction.delete(roomRef); // Delete the room if no users are left
      } else {
        transaction.update(roomRef, {'users': users}); // Update the users array
      }
    }
  }).catchError((error) {
    // Handle any errors that occur during the transaction
    print('Error removing user and handling room deletion: $error');
  });
}

Future<void> showLeaveRoomDialog({
  required BuildContext context,
  required String userEmail,
  required String roomId, required String email, required String userName,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Leave Room'),
        content: Text('Are you sure you want to leave the room? The app will restart.'),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () async {
              // Perform the user removal and room deletion logic
              await removeUserAndHandleRoomDeletion(
                context: context,
                userEmail: userEmail,
                roomId: roomId,
              );

              // After the process is done, navigate to SplashScreen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => SplashScreen(),
                ),
                    (Route<dynamic> route) => false, // Remove all previous routes
              );
            },
          ),
        ],
      );
    },
  );
}
