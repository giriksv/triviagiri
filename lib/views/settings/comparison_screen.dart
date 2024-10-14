import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/background_color_utils.dart';
import '../../utils/custom_app_bar.dart';
import '../../utils/gifutils.dart';

class ComparisonScreen extends StatefulWidget {
  final String otherUserEmail;

  ComparisonScreen({required this.otherUserEmail});

  @override
  _ComparisonScreenState createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: customAppBar(), // Fixed AppBar
      backgroundColor: BackgroundColorUtils.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // My user details with the custom container style
                  Flexible(
                    child: _buildUserSection(userEmail, true),
                  ),

                  // The GIF in between two profiles
                  Container(
                    width: 40, // Adjust the size as needed
                    height: 40, // Adjust the size as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Make it a circle
                      border: Border.all(
                        color: Colors.black, // Black border
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Optional padding inside the circle
                      child: Image.asset(
                        'assets/gif/vs.gif',
                        fit: BoxFit.cover, // Ensure the GIF covers the container
                      ),
                    ),
                  ),

                  // Other user details with the custom container style
                  Flexible(
                    child: _buildUserSection(widget.otherUserEmail, false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(String? email, bool isCurrentUser) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(email).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('User not found!',
              style: TextStyle(fontSize: 18, color: Colors.red));
        }

        final userData = snapshot.data!;
        final userName = userData['name'] ?? "Not Available";
        final userCharacter = userData['selectedCharacter'] ?? "Not Available";
        final userPoints = userData['points'] ?? 0;

        // Cast userData.data() to Map<String, dynamic> and check for null
        final categoryPoints = <String, dynamic>{};
        final data = userData.data() as Map<String, dynamic>?;

        if (data != null) {
          data.forEach((key, value) {
            if (key.startsWith('categoryPoints.')) {
              // Extract category name and its points
              final category = key.split('categoryPoints.')[1];
              categoryPoints[category] = value;
            }
          });
        }

        // Get the GIF path using CharacterUtils
        final gifPath = CharacterUtils.getCharacterGif(userCharacter);

        // Apply the background and border styles based on whether it's the current user
        final containerDecoration = BoxDecoration(
          color: isCurrentUser ? Color(0xFFE76A89) : Color(0xFF4C2F54),
          border: Border.all(color: Colors.white, width: 4),
          borderRadius: BorderRadius.circular(25), // Curved edges
        );

        return Stack(
          clipBehavior: Clip.none, // This allows the avatar to overflow outside the container
          children: [
            // The main container for user info
            Container(
              decoration: containerDecoration,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                mainAxisSize: MainAxisSize.min, // Adjusts the height based on content
                children: [
                  SizedBox(height: 50), // Add space for the avatar's height above the text
                  Text(
                    userName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.left, // Ensure left alignment
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Character: $userCharacter',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.left, // Ensure left alignment
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Points: $userPoints',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.left, // Ensure left alignment
                  ),
                  SizedBox(height: 10),
                  _buildCategoryPointsSection(categoryPoints), // Show category points
                ],
              ),
            ),
            // The CircleAvatar that overflows the top of the container
            Positioned(
              top: -50, // This positions the avatar to overflow from the top
              left: 25, // Adjust as necessary for horizontal positioning
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isCurrentUser ? Color(0xFFDE6786) : Color(0xFF4C2F54), // Set border color based on user
                    width: 4,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: gifPath != null
                      ? Image.asset(gifPath)
                      : Icon(Icons.person, size: 50), // Fallback icon
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to display category-wise points
  Widget _buildCategoryPointsSection(Map<String, dynamic> categoryPoints) {
    if (categoryPoints.isEmpty) {
      return Text('No category points available',
          style: TextStyle(fontSize: 14, color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryPoints.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text('${entry.key}: ${entry.value}',
              style: TextStyle(fontSize: 14, color: Colors.white)),
        );
      }).toList(),
    );
  }
}
