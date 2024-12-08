import 'package:flutter/material.dart';

class CompanyCard extends StatelessWidget {
  final Map<String, dynamic> companyData;
  final Color gradient1;
  final Color gradient2;
  final Color buttonColor;
  final Color iconColor;
  final Function showDetails;
  final Function sendMessage;
  final Function showFiles;

  const CompanyCard({
    required this.companyData,
    required this.gradient1,
    required this.gradient2,
    required this.buttonColor,
    required this.iconColor,
    required this.showDetails,
    required this.sendMessage,
    required this.showFiles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Köşeler
      ),
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient1, gradient2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10), // Köşeler yuvarlatıldı
        ),
        padding: const EdgeInsets.all(8), // İçerik için padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Company Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  companyData['companyName'] ?? 'Unknown Company',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => showDetails(),
                  child: Icon(Icons.info, color: iconColor),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => sendMessage(),
                  child: Icon(Icons.message, color: iconColor),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => showFiles(),
                  child: Icon(Icons.folder, color: iconColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
