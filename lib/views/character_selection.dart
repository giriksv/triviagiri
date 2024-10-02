import 'package:flutter/material.dart';
import '../controller/all_db_controller.dart';
import '../utils/custom_app_bar.dart';
import '../utils/gifutils.dart';
import '../utils/background_color_utils.dart'; // Import the BackgroundColorUtils
import '../model/user_model.dart';
import 'modeselection_screen.dart';

class CharacterSelectionScreen extends StatelessWidget {
  final String email;
  final String name;
  final int points;

  CharacterSelectionScreen({
    required this.email,
    required this.name,
    required this.points,
  });

  final List<String> characters = ['Boy', 'Girl', 'Tiger', 'Robo'];
  final List<Color> borders = [
    Color(0xFFDE6786), // Border color for 'Boy'
    Color(0xFF981EA9), // Border color for 'Girl'
    Color(0xFFEAB834), // Border color for 'Tiger'
    Color(0xFF7D7E80), // Border color for 'Robo'
  ];

  final AllDBController _dbController = AllDBController();

  void _selectCharacter(BuildContext context, String character) async {
    int updatedPoints = points ;

    // Create a UserModel instance with the updated points
    UserModel user = UserModel(
      email: email,
      character: character,
      name: name,
      points: updatedPoints, // Use the updated points
      categoryPoints: {},
    );

    // Insert user data into Firestore
    await _dbController.insertUserData(user);

    // Navigate to the ModeSelectionScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ModeSelectionScreen(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(), // Use the custom app bar
      backgroundColor: BackgroundColorUtils.backgroundColor, // Use the background color from utils
      body: SingleChildScrollView( // Make the body scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Flex( // Use Flex for better layout control
            direction: Axis.vertical,
            children: [
              SizedBox(height: 42),
              Text(
                'Choose your Character',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Change color as per your need
                ),
                textAlign: TextAlign.center, // Center align text
              ),
              SizedBox(height: 100),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(), // Prevent scrolling within GridView
                shrinkWrap: true, // Make GridView take only the needed space
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Display two characters per row
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  String character = characters[index];
                  String? gifPath = CharacterUtils.getCharacterGif(character); // Get GIF path

                  return GestureDetector(
                    onTap: () => _selectCharacter(context, character),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Use a Stack to overlay the emoji on the CircleAvatar
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // CircleAvatar with border
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: borders[index], // Apply the corresponding border color
                                  width: 4, // Border width
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: gifPath != null ? AssetImage(gifPath) : null,
                                child: gifPath == null
                                    ? Icon(Icons.person, size: 50) // Fallback icon
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          character,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black, // Adjust color if necessary
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
