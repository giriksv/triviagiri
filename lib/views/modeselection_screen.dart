import 'package:flutter/material.dart';
import '../utils/background_color_utils.dart';
import '../utils/custom_app_bar.dart';
import 'category_screen.dart';
import '../multiplayer/multi_player_views/room_type_screen.dart'; // Import the RoomTypeScreen
import 'settings/leaderboard_screen.dart'; // Import your leaderboard screen
import 'settings/settings_screen.dart'; // Import your settings screen

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
      appBar: customAppBar(showBackButton: false), // Add the custom AppBar
      backgroundColor: BackgroundColorUtils.backgroundColor, // Set background color using BackgroundColorUtils
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding for some spacing
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20), // Space after the app bar

            // "Ready!" Text
            Text(
              'Ready!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Space between "Ready!" and the next text

            // "Choose your mode to play your game" Text in two lines
            Text(
              'Choose your mode\nto play your game',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF7D7E80), // Hex color #7D7E80
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40), // Add space before buttons

            // Single Player Button
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
              child: Text(
                "Single Player",
                style: TextStyle(
                  color: Colors.white, // White text color
                  fontWeight: FontWeight.bold, // Bold text
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4C2F54), // Background color #4C2F54
                padding: EdgeInsets.symmetric(horizontal: 65, vertical: 15),
              ),
            ),
            SizedBox(height: 20), // Add space between buttons

            // Multiplayer Button
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
              child: Text(
                "Multi player",
                style: TextStyle(
                  color: Colors.white, // White text color
                  fontWeight: FontWeight.bold, // Bold text
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4C2F54), // Background color #4C2F54
                padding: EdgeInsets.symmetric(horizontal: 65, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
