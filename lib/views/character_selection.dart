import 'package:flutter/material.dart';
import '../controller/db_controller.dart';
import 'category_screen.dart';
import '../controller/auth_controller.dart';

class CharacterSelectionScreen extends StatelessWidget {
  final String email;

  CharacterSelectionScreen({required this.email});

  final List<String> characters = ['Character 1', 'Character 2', 'Character 3'];
  final DBController _dbController = DBController();

  void _selectCharacter(BuildContext context, String character) async {
    await _dbController.insertUserData(email, character);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CategoryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Character')),
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
