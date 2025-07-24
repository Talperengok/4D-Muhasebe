import 'package:flutter/material.dart';

///THE WIDGET WHICH SHOWN IN ACCOUNTANT MAIN PAGE FOR EACH COMPANY

class CompanyCard extends StatelessWidget {
  final Map<String, dynamic> companyData; //Company Data (name, id, files, messages etc.)
  final Color gradient1; //Card Gradient's 1st color
  final Color gradient2; //Card Gradient's 2nd color
  final Color buttonColor; //Card buttons' color
  final Color iconColor; //Buttons' icons' color
  final Function showDetails; //Function That Showing Company Info
  final Function sendMessage; //Function That Redirects Accountant to Chat Page with Company
  final Function showFiles; //Function That Redirects Accountant to File View Page of Company
  final Function archiveClient; //Function That Archives the Client

  const CompanyCard({
    required this.companyData,
    required this.gradient1,
    required this.gradient2,
    required this.buttonColor,
    required this.iconColor,
    required this.showDetails,
    required this.sendMessage,
    required this.showFiles,
    required this.archiveClient,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4, // Hafif gölge efekti
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient1, gradient2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(8),
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
                    color: Color(0xFFEFEFEF),
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
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => archiveClient(), // yeni fonksiyon
                  child: const Icon(Icons.archive, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
