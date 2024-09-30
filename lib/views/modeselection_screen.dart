import 'package:flutter/material.dart';
import 'category_screen.dart';
import '../multiplayer/multi_player_views/room_type_screen.dart'; // Import the RoomTypeScreen

class ModeSelectionScreen extends StatelessWidget {
  final String email;

  ModeSelectionScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Mode"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose Your Mode:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20), // Add some space between the text and buttons
          ElevatedButton(
            onPressed: () {
              // Navigate to CategoryScreen for Single Player
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(email: email),
                ),
              );
            },
            child: Text("Single Player"),
          ),
          SizedBox(height: 20), // Add space between buttons
          ElevatedButton(
            onPressed: () {
              // Navigate to RoomTypeScreen for Multiplayer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomTypeScreen(email: email),
                ),
              );
            },
            child: Text("Multiplayer"),
          ),
        ],
      ),
    );
  }
}