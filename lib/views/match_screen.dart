import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comparison_screen.dart'; // Ensure this import is correct

class MatchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matches'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points',
                descending: true) // Order by points in descending order
            .limit(5) // Limit to top 5 users
            .snapshots(), // Use snapshots for real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No matches found.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];

              // Ensure 'email' exists
              if (user['email'] == null) {
                return SizedBox.shrink(); // Skip this user if no email
              }

              // Safely check for 'name' and 'points' fields
              var userData =
                  user.data() as Map<String, dynamic>?; // Cast to Map
              String userName = userData?['name'] ?? 'Unknown User';
              String userPoints = userData?['points']?.toString() ?? '0';

              return ListTile(
                title: Text(userName),
                subtitle: Text('Points: $userPoints'),
                trailing: Text(
                  (index + 1).toString(), // Display the ranking number here
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Adjust font size to your liking
                  ),
                ),
                onTap: () {
                  // Navigate to UserProfileScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ComparisonScreen(otherUserEmail: user['email']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
