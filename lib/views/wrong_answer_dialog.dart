// screen/wrong_answer_dialog.dart
import 'package:flutter/material.dart';
import '../utils/background_color_utils.dart'; // Import your BackgroundColorUtils

class WrongAnswerDialog extends StatelessWidget {
  final String? correctAnswer;
  final VoidCallback onNext;

  const WrongAnswerDialog({Key? key, this.correctAnswer, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BackgroundColorUtils.backgroundColor, // Use the background color
      title: Center(
        child: Text(
          'Wrong Answer',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display the GIF
            Container(
              height: 100, // Adjust height as needed
              child: Image.asset(
                'assets/gif/wronganswer.gif', // Path to your GIF
                fit: BoxFit.cover, // Ensure the GIF fits the container
              ),
            ),
            SizedBox(height: 20),
            // Container for correct answer
            Container(
              padding: EdgeInsets.all(16), // Padding inside the container
              decoration: BoxDecoration(
                color: Colors.white, // White background
                border: Border.all(color: Color(0xFFFA7B95), width: 4), // Border color and width
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Column(
                children: [
                  Text(
                    ' correct answer',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    correctAnswer ?? 'N/A',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Add space before the button
          ],
        ),
      ),
      actions: [
        // Centering the button using a Row
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onNext();
            },
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFDE6786), // Button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Curved edges
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Button padding
            ),
            child: Text(
              'Next Question',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Bold white text
            ),
          ),
        ),
      ],
    );
  }
}
