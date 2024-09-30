// join_room_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'waiting_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  final String email;
  final int maxUsers;

  JoinRoomScreen({required this.email, this.maxUsers = 2});

  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  // Fetch user's name from Firestore
  Future<String> _fetchUserName() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot['name'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Unknown';
    }
  }

  // Handle joining the room
  Future<void> _joinRoom() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String roomId = _roomIdController.text.trim();

      try {
        DocumentReference roomRef =
        FirebaseFirestore.instance.collection('rooms').doc(roomId);
        DocumentSnapshot roomSnapshot = await roomRef.get();

        if (!roomSnapshot.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Room does not exist')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        Map<String, dynamic> roomData =
        roomSnapshot.data() as Map<String, dynamic>;

        int maxUsers = roomData['maxUsers'] ?? widget.maxUsers;
        List<dynamic> usersDynamic = roomData['users'] ?? [];

        // Convert List<dynamic> to List<Map<String, dynamic>>
        List<Map<String, dynamic>> users = usersDynamic.cast<Map<String, dynamic>>();

        // Check if room is full
        if (users.length >= maxUsers) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Room is already full')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Check if user is already in the room
        bool alreadyInRoom = users.any((user) => user['email'] == widget.email);
        if (alreadyInRoom) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You are already in this room')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Fetch user's name
        String userName = await _fetchUserName();

        // Add user to the room
        await roomRef.update({
          'users': FieldValue.arrayUnion([
            {
              'email': widget.email,
              'name': userName,
              'roomPoints': 0,
            }
          ]),
          // Remove from invitedUsers if present
          'invitedUsers': FieldValue.arrayRemove([widget.email]),
        });

        // Navigate to WaitingScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingScreen(
              roomName: roomData['roomName'] ?? 'Unknown',
              roomId: roomId,
              maxUsers: maxUsers,
              email: widget.email, members: [],
            ),
          ),
        );
      } catch (e) {
        print('Error joining room: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join room')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Build the Join Room UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join Room"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  labelText: 'Enter Room ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Room ID';
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