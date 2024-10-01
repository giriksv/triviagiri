import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/all_db_controller.dart';
import '../model/single_player_quiz_model.dart';
import '../utils/categoryutils.dart';
import 'quiz_screen.dart';

AppBar customAppBar() {
  return AppBar(
    title: ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Color(0xFF04143C), // Start color (dark blue)
          Color(0xFFFB7290), // Middle color (pink)
          Color(0xFFF7C6BF), // End color (light peach)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Text(
        'Trivia',
        style: GoogleFonts.outfit(
          textStyle: TextStyle(
            fontSize: 54, // Font size: 54px
            fontWeight: FontWeight.w800, // Font weight: 800
            letterSpacing: 0.75, // Letter spacing: 0.75em
            height: 68.84 / 54, // Line-height: Adjusted for 54px
            color: Colors.white, // Default color to make text visible with gradient
            shadows: [
              Shadow(
                offset: Offset(2, 2), // Slightly offset shadow for bottom-right
                color: Colors.black, // Border color
                blurRadius: 5.0, // Blur radius for the shadow
              ),
              Shadow(
                offset: Offset(-2, 2), // Slightly offset shadow for bottom-left
                color: Colors.black, // Border color
                blurRadius: 5.0, // Blur radius for the shadow
              ),
              Shadow(
                offset: Offset(2, -2), // Slightly offset shadow for top-right
                color: Colors.black, // Border color
                blurRadius: 5.0, // Blur radius for the shadow
              ),
              Shadow(
                offset: Offset(-2, -2), // Slightly offset shadow for top-left
                color: Colors.black, // Border color
                blurRadius: 5.0, // Blur radius for the shadow
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center, // Align text to the center
      ),
    ),
    centerTitle: true,
    backgroundColor: Color(0xFFFFEDEC),
    elevation: 4, // Optionally add elevation for a shadow effect
  );
}

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
        builder: (context) => QuizScreen(quizzes: quizzes, category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(), // Use custom AppBar
      body: Container(
        color: Color(0xFFFFEDEC), // Background color
        child: Center( // Center the button column
          child: SingleChildScrollView( // Use SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center buttons vertically
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
        ),
      ),
    );
  }
}
