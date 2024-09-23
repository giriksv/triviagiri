import 'package:flutter/material.dart';
import '../controller/db_controller.dart';
import 'category_screen.dart';
import '../model/user_model.dart'; // Assuming you have UserModel

class CharacterSelectionScreen extends StatelessWidget {
  final String email;
  final String name; // Added name parameter for greeting

  CharacterSelectionScreen({
    required this.email,
    required this.name,
  });

  final List<String> characters = ['Character 1', 'Character 2', 'Character 3'];
  final DBController _dbController = DBController();

  void _selectCharacter(BuildContext context, String character) async {
    UserModel user = UserModel(email: email, character: character, name: name); // Create user model
    await _dbController.insertUserData(user); // Insert user data into Firestore
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CategoryScreen(email: '',)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Character'),
      ),
      body: ListView.builder(
        itemCount: characters.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(characters[index]),
            onTap: () => _selectCharacter(context, characters[index]),
          );
        },
      ),
    );
  }
}
