import 'package:flutter/material.dart';
import 'waiting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRoomScreen extends StatefulWidget {
  final String email;
  final int maxUsers; // Add this line

  JoinRoomScreen({required this.email, required this.maxUsers}); // Update constructor

  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomCodeController = TextEditingController();

  Future<void> _joinRoom() async {
    if (_formKey.currentState!.validate()) {
      String roomId = _roomCodeController.text;
      DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();

      if (roomSnapshot.exists) {
        List users = roomSnapshot['users'];
        int maxUsers = roomSnapshot['maxUsers'];

        if (users.length < maxUsers) {
          // Fetch the user's name from Firestore
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.email).get();
          String userName = userSnapshot.exists ? userSnapshot['name'] : 'Unknown';

          // Add the user to the room with initialized roomPoints = 0
          users.add({
            'email': widget.email,
            'name': userName,
            'roomPoints': 0,  // Initialize roomPoints for joiners
          });

          await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
            'users': users,
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaitingScreen(
                roomName: roomSnapshot['roomName'],
                roomId: roomId,
                members: users,
                maxUsers: maxUsers,
              ),
            ),
          );
        } else {
          _showErrorDialog("Room is full!");
        }
      } else {
        _showErrorDialog("Room does not exist!");
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Join Room")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _roomCodeController,
                decoration: InputDecoration(labelText: 'Room Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _joinRoom,
                child: Text("Join Room"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}