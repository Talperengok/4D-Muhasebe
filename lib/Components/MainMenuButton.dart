import 'package:flutter/material.dart';

///BUTTONS THAT SHOWN IN THE MAIN MENU PAGE (2nd Page for Accountants, Main Page for Clients)

class MainMenuButton extends StatelessWidget {
  final Color gradient1; //Button Gradient's 1st Color
  final Color gradient2; //Button Gradient's 2nd Color
  final double height; //Button Height
  final double width; //Button Width
  final String title; //Button Title
  final String informerText; //Button Informer
  final String imagePath; //Button's Icon Path In Assets
  final Function onPressed; // What will be when press button?

  const MainMenuButton({
    super.key,
    required this.gradient1,
    required this.gradient2,
    required this.height,
    required this.width,
    required this.title,
    required this.informerText,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient1, gradient2, gradient1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: height * 0.6,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                informerText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
