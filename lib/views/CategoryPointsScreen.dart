import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/background_color_utils.dart';
import '../utils/custom_app_bar.dart';
import '../utils/gifutils.dart';

class CategoryPointsScreen extends StatefulWidget {
  final String userEmail;

  CategoryPointsScreen({required this.userEmail, required String userName});

  @override
  _CategoryPointsScreenState createState() => _CategoryPointsScreenState();
}

class _CategoryPointsScreenState extends State<CategoryPointsScreen> {
  String selectedCharacter = 'Boy'; // Default character
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data including selected character and points
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userData = userSnapshot.data() as Map<String, dynamic>;
          selectedCharacter = userData!['selectedCharacter'] ?? 'Boy'; // Update selected character if available
        });
        print('User data fetched: $userData');
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Fetch category points from Firestore
  Future<Map<String, int>> _fetchCategoryPoints() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        Map<String, int> categoryPoints = {};

        // Filter out fields that start with 'categoryPoints.'
        userData.forEach((key, value) {
          if (key.startsWith('categoryPoints.') && value is int) {
            String categoryName = key.replaceFirst('categoryPoints.', '');
            categoryPoints[categoryName] = value;
          }
        });

        print('Category points fetched: $categoryPoints');
        return categoryPoints;
      }

      return {};
    } catch (e) {
      print('Error fetching category points: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        showBackButton: true,
        onBackPressed: () {
          Navigator.pop(context); // Back navigation
        },
      ),
      body: Container(
        color: BackgroundColorUtils.backgroundColor, // Background color
        child: Column(
          children: [
            // Fixed content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (userData != null) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Show the GIF for the current user's selected character
                            if (userData!['selectedCharacter'] != null)
                              Image.asset(
                                CharacterUtils.getCharacterGif(selectedCharacter) ?? '',
                                width: 150,
                                height: 150,
                              ),
                            SizedBox(height: 16),
                            // User's Name in bold with black color (fetching from Firestore)
                            if (userData!['name'] != null)
                              Text(
                                userData!['name'], // Display name from Firestore
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Set text color to black
                                ),
                              ),
                            SizedBox(height: 8),
                            // Total Points
                            GestureDetector(
                              onTap: () {
                                // Total points tap action (optional)
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(width: 8),
                                    Text(
                                      'Total Points: ${userData!['points']?.toString() ?? '0'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Category Points heading
                            Text(
                              'Category Points',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center, // Align center
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Scrollable container for category points
// Scrollable container for category points
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFFBC1CD), // Background color #FBC1CD
                    border: Border.all(
                      color: Color(0xFFFA7B95), // Border color #FA7B95
                      width: 4, // Border width
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9, // Reduced width of container
                  child: FutureBuilder<Map<String, int>>(
                    future: _fetchCategoryPoints(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No category points available.'));
                      }

                      final categoryPoints = snapshot.data!;

                      return Column(
                        children: categoryPoints.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensure even spacing
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Button background color
                                      borderRadius: BorderRadius.circular(20), // Curved edges
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Category name aligned to the left
                                        Expanded(
                                          child: Text(
                                            entry.key,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        // Points with fixed width for alignment
                                        SizedBox(
                                          width: 60, // Fixed width for points
                                          child: Text(
                                            entry.value.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.right, // Right align the points
                                          ),
                                        ),
                                        // Reward icon straight for all categories
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, right: 16.0), // Space around icon
                                          child: Icon(
                                            Icons.star, // Reward icon
                                            color: Colors.amber,
                                            size: 24, // Adjust size if needed
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),

    );
  }
}
