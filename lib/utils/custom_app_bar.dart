import 'package:flutter/material.dart';

AppBar customAppBar({bool showBackButton = false, VoidCallback? onBackPressed}) {
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
        style: TextStyle(
          fontSize: 54, // Font size
          fontWeight: FontWeight.w800, // Font weight
          letterSpacing: 0.75, // Letter spacing
          height: 68.84 / 54, // Line-height
          color: Colors.white, // Text color
          shadows: [
            Shadow(
              offset: Offset(2, 2), // Shadow offset
              color: Colors.black, // Shadow color
              blurRadius: 5.0, // Blur radius
            ),
          ],
        ),
        textAlign: TextAlign.center, // Align text to the center
      ),
    ),
    centerTitle: true,
    backgroundColor: Color(0xFFFFEDEC),
    elevation: 4,
    leading: showBackButton
        ? IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: onBackPressed, // Call the function passed
    )
        : null, // No back button if not required
  );
}
