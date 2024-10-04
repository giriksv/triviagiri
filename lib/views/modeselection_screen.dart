import 'package:flutter/material.dart';
import '../utils/background_color_utils.dart';
import '../utils/custom_app_bar.dart';
import 'category_screen.dart';
import '../multiplayer/multi_player_views/room_type_screen.dart';
import 'settings/leaderboard_screen.dart';
import 'settings/settings_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  String email;  // Changed to String, as we need to pass email and update it later.

  ModeSelectionScreen({required this.email});

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildModeSelectionScreen(),
      LeaderBoardScreen(),
      SettingsScreen(),
    ];
    print('ModeSelectionScreen: initState called'); // Debug statement
  }

  @override
  Widget build(BuildContext context) {
    print('ModeSelectionScreen: build called'); // Debug statement

    return Scaffold(
      appBar: customAppBar(showBackButton: false),
      backgroundColor: BackgroundColorUtils.backgroundColor,
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

  void _onBottomNavTapped(int index) {
    print('Bottom Navigation Tapped: $index'); // Debug statement
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildModeSelectionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Ready!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Choose your mode\nto play your game',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF7D7E80),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                print('Single Player button pressed'); // Debug statement
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4C2F54),
                padding: EdgeInsets.symmetric(horizontal: 65, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print('Multi Player button pressed'); // Debug statement
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomTypeScreen(email: widget.email),
                  ),
                );

                // Check if email is returned when back button is pressed.
                if (result != null) {
                  print('Returned email from RoomTypeScreen: $result');
                  setState(() {
                    widget.email = result;  // Update email after navigating back.
                  });
                }
              },
              child: Text(
                "Multi player",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4C2F54),
                padding: EdgeInsets.symmetric(horizontal: 65, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
