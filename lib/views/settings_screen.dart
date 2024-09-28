import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'daily_rewards.dart';

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
      appBar: AppBar(title: Text('Settings')),
      body: FutureBuilder<Map<String, dynamic>>(
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
          final userCharacter = userData['selectedCharacter'] ?? 'N/A'; // Get selected character

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          name: userName,  // Pass the fetched name
                          email: userEmail, // Pass the fetched email
                          selectedCharacter: userCharacter, // Pass selected character
                          points: userPoints, // Pass points
                        ),
                      ),
                    );
                  },
                ),
                // ListTile(
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
                ListTile(
                  title: Text('Privacy Policy'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Terms and Conditions'),
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
