import 'package:flutter/material.dart';
import 'category_screen.dart';
import '../multiplayer/multi_player_views/room_type_screen.dart'; // Import the RoomTypeScreen
import 'leaderboard_screen.dart'; // Import your leaderboard screen
import 'settings_screen.dart'; // Import your settings screen

class ModeSelectionScreen extends StatefulWidget {
  final String email;

  ModeSelectionScreen({required this.email});

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int _selectedIndex = 0;

  // List of screens for bottom navigation
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildModeSelectionScreen(),
      LeaderBoardScreen(), // Pass email to LeaderboardScreen
      SettingsScreen(), // Pass email to SettingsScreen
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  // Function to handle bottom navigation bar tap
  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to build the mode selection screen
  Widget _buildModeSelectionScreen() {
    return Column(
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
                builder: (context) => CategoryScreen(email: widget.email),
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
                builder: (context) => RoomTypeScreen(email: widget.email),
              ),
            );
          },
          child: Text("Multiplayer"),
        ),
      ],
    );
  }
}
