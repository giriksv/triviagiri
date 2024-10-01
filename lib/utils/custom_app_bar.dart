import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure you have the Google Fonts package for Outfit

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
              // Create a shadow effect to simulate a border
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
