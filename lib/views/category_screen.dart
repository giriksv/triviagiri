import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for Google Fonts
import '../controller/all_db_controller.dart';
import '../model/single_player_quiz_model.dart';
import '../utils/categoryutils.dart';
import '../utils/custom_app_bar.dart';
import 'modeselection_screen.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String email;

  CategoryScreen({required this.email});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<String> _categories = CategoryUtils.categories;
  final AllDBController _dbController = AllDBController();

  final List<Color> _buttonColors = [
    Color(0xFF981EA9), // First category color
    Color(0xFFFB7290), // Second category color
    Color(0xFF01CCCA), // Third category color
    Color(0xFFEAB834), // Fourth category color
  ];

  @override
  void initState() {
    super.initState();
    updateUserTimestamp();
  }

  Future<void> updateUserTimestamp() async {
    await _dbController.updateUserTimestamp(widget.email);
  }

  void _selectCategory(BuildContext context, String category) async {
    List<QuizModel> quizzes = await _dbController.getQuizzesByCategory(category);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          quizzes: quizzes,
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        showBackButton: true, // Show the back button
        onBackPressed: () {
          // Navigate back to ModeSelectionScreen when back arrow is clicked
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ModeSelectionScreen(email: widget.email),
            ),
          );
        },
      ),
      body: Container(
        color: Color(0xFFFFEDEC), // Background color
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20), // Add some space below the AppBar
              Text(
                'Choose Your Category',
                style: GoogleFonts.outfit(
                  textStyle: TextStyle(
                    fontSize: 28, // Font size for the heading
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC85E7E), // Pink color
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20), // Space between the heading and buttons
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_categories.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 250, // Set a fixed width for buttons
                        child: ElevatedButton(
                          onPressed: () => _selectCategory(context, _categories[index]),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonColors[index % _buttonColors.length],
                            padding: EdgeInsets.symmetric(vertical: 12), // Reduced vertical padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Rounded edges
                            ),
                          ),
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18, // Font size for button text
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
