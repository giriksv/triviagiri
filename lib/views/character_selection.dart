import 'package:flutter/material.dart';
import '../controller/all_db_controller.dart';
import '../utils.dart';
import 'category_screen.dart';
import '../model/user_model.dart';

class CharacterSelectionScreen extends StatelessWidget {
  final String email;
  final String name;

  CharacterSelectionScreen({
    required this.email,
    required this.name,
  });

  final List<String> characters = ['Boy', 'Girl', 'Robo', 'Tiger'];
  final AllDBController _dbController = AllDBController();

  void _selectCharacter(BuildContext context, String character) async {
    UserModel user = UserModel(email: email, character: character, name: name);
    await _dbController.insertUserData(user); // Insert user data into Firestore

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Character'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a character to proceed:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Display two characters per row
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  String character = characters[index];
                  String? gifPath =
                      CharacterUtils.getCharacterGif(character); // Get GIF path

                  return GestureDetector(
                    onTap: () => _selectCharacter(context, character),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                gifPath != null ? AssetImage(gifPath) : null,
                            child: gifPath == null
                                ? Icon(Icons.person, size: 50)
                                : null,
                          ),
                          SizedBox(height: 10),
                          Text(
                            character,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
