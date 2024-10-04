import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/background_color_utils.dart';
import '../../utils/custom_app_bar.dart';
import '../../utils/gifutils.dart';
import 'CategoryPointsScreen.dart';
import 'comparison_screen.dart';

class LeaderBoardScreen extends StatefulWidget {
  @override
  _LeaderBoardScreenState createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentUserEmail;
  Map<String, dynamic>? currentUserData;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData();
  }

  // Method to fetch current user's data
  Future<void> _fetchCurrentUserData() async {
    currentUserEmail = _auth.currentUser?.email;
    if (currentUserEmail != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserEmail)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          currentUserData = userSnapshot.data() as Map<String, dynamic>;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: customAppBar(
      //   showBackButton: true,
      //   onBackPressed: () {
      //     Navigator.pop(context); // Navigate to the previous screen
      //   },
      // ),
      body: Container(
        color: BackgroundColorUtils.backgroundColor,
        child: Column(
          children: [
            // Display current user's GIF, name, and points
            if (currentUserData != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Show the GIF for the current user's selected character
                      if (currentUserData!['selectedCharacter'] != null)
                        Image.asset(
                          CharacterUtils.getCharacterGif(currentUserData!['selectedCharacter'])!,
                          width: 150, // Adjust the size as needed
                          height: 150,
                        ),
                      SizedBox(height: 16),
                      Text(
                        currentUserData!['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Points Button
// Inside the GestureDetector for the Total Points button
                      GestureDetector(
                        onTap: () {
                          // Navigate to the CategoryPointsScreen and pass the current user's email
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryPointsScreen(userEmail: currentUserEmail!, userName: '',),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.green, // Green background color
                            borderRadius: BorderRadius.circular(12), // Curved edges
                            border: Border.all(color: Colors.white, width: 4), // White border
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Adjust size based on content
                            children: [
                              SizedBox(width: 8), // Spacing between icon and text
                              Text(
                                'Total Points : ${currentUserData!['points']?.toString() ?? '0'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Text color
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),

            // Top Rankers text
            Text(
              'Top Rankers',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Curved Container for the List of Rankers
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFFBC1CD), // Background color
                    border: Border.all(color: Color(0xFFFA7B95), width: 4), // Border color and width
                    borderRadius: BorderRadius.circular(16), // Curved edges
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .orderBy('points', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No users found.'));
                      }

                      final users = snapshot.data!.docs;

                      return Column(
                        children: users.map((user) {
                          var userData = user.data() as Map<String, dynamic>;

                          String userName = userData['name'] ?? 'Unknown User';
                          String userPoints = userData['points']?.toString() ?? '0';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0), // Spacing between buttons
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to ComparisonScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ComparisonScreen(otherUserEmail: user['email'] ?? 'unknown'),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white, // Button background color
                                  borderRadius: BorderRadius.circular(12), // Curved edges
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5), // Shadow color
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3), // Changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        userName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        overflow: TextOverflow.ellipsis, // Prevent overflow
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow, // Star icon color
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          userPoints,
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16), // Add some spacing below the button
          ],
        ),
      ),
    );
  }
}
