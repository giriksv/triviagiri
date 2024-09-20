import 'package:flutter/material.dart';
import '../controller/db_controller.dart';
import '../model/quiz_model.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatelessWidget {
  final List<String> categories = ['Technology', 'History', 'AI', 'Culture'];
  final DBController _dbController = DBController();

  void _selectCategory(BuildContext context, String category) async {
    // Navigate to quiz screen and fetch quizzes based on category
    List<QuizModel> quizzes = await _dbController.getQuizzesByCategory(category);
    Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(quizzes: quizzes, category: '',)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Category')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            onTap: () => _selectCategory(context, categories[index]),
          );
        },
      ),
    );
  }
}
