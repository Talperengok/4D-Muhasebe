import 'package:flutter/material.dart';


class MainMenuButton extends StatelessWidget {
  final Color gradient1;
  final Color gradient2;
  final double height;
  final double width;
  final String title;
  final String informerText;
  final String imagePath;
  final Function onPressed;

  const MainMenuButton({
    Key? key,
    required this.gradient1,
    required this.gradient2,
    required this.height,
    required this.width,
    required this.title,
    required this.informerText,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 8), // Dikey boşluk
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient1, gradient2, gradient1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20), // Görseldeki gibi köşeler yuvarlatılmış
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
            // Ortadaki Image ve Text Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: height * 0.6, // Butonun %40'ı kadar boyut
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
            // Alttaki açıklama Text
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
