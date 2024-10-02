import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/background_color_utils.dart';
import '../utils/custom_app_bar.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
//import 'daily_rewards.dart';

class SettingsScreen extends StatelessWidget {
  Future<Map<String, dynamic>> _getUserData() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(userEmail).get();
      return snapshot.data() ?? {};
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        showBackButton: false,
      ),
      body: Container(
        color: BackgroundColorUtils.backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Title
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20), // Add some space between title and list

            FutureBuilder<Map<String, dynamic>>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(child: Text('Error fetching data'));
                }

                final userData = snapshot.data!;
                final userName = userData['name'] ?? 'N/A';
                final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'N/A';
                final userPoints = userData['points'] ?? 0;
                final userCharacter = userData['selectedCharacter'] ?? 'N/A';

                return Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person), // Icon for Profile
                        title: Text('Profile'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                name: userName,
                                email: userEmail,
                                selectedCharacter: userCharacter,
                                points: userPoints,
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(), // Divider after Profile

                      // ListTile(
                      //   leading: Icon(Icons.star), // Icon for Daily Rewards
                      //   title: Text('Daily Rewards'),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => DailyRewardsScreen(),
                      //       ),
                      //     );
                      //   },
                      // ),

                      ListTile(
                        leading: Icon(Icons.leaderboard), // Icon for Leader Board
                        title: Text('Leader Board'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaderBoardScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(), // Divider after Leader Board

                      ListTile(
                        leading: Icon(Icons.privacy_tip), // Icon for Privacy Policy
                        title: Text('Privacy Policy'),
                        onTap: () {
                          // Implement navigation to Privacy Policy
                        },
                      ),
                      Divider(), // Divider after Privacy Policy

                      ListTile(
                        leading: Icon(Icons.description), // Icon for Terms and Conditions
                        title: Text('Terms and Conditions'),
                        onTap: () {
                          // Implement navigation to Terms and Conditions
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
