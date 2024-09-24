import 'package:flutter/material.dart';
import '../controller/all_db_controller.dart';
import '../model/quiz_model.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String email; // Add this to accept email

  CategoryScreen(
      {required this.email}); // Modify the constructor to accept email

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<String> categories = ['Technology', 'History', 'AI', 'Culture'];
  final AllDBController _dbController = AllDBController();

  @override
  void initState() {
    super.initState();
    updateUserTimestamp();
  }

  Future<void> updateUserTimestamp() async {
    await _dbController.updateUserTimestamp(widget.email);
  }

  void _selectCategory(BuildContext context, String category) async {
    // Navigate to quiz screen and fetch quizzes based on category
    List<QuizModel> quizzes =
        await _dbController.getQuizzesByCategory(category);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QuizScreen(
              quizzes: quizzes,
              category: category)), // Pass the category to QuizScreen
    );
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
