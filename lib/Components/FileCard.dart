import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';


/// THE WIDGET FOR EACH FILE THAT SHOWN IN FILE VIEW PAGE
class FileCard extends StatelessWidget {
  final Color gradient1; //Card Gradient's 1st Color
  final Color gradient2; //Card Gradient's 2nd Color
  final Color buttonColor; // Card Buttons' Color
  final Color iconColor; // Card Buttons' Icons' Color
  final String filePath; // Files' Path On The Server
  final String imagePath; // File Type Image Path In Assets
  final Function showInfo; // Show File Info Function
  final Function downloadFile; // Download File Function
  final Function shareFile; // Share File Function

  const FileCard({
    required this.gradient1,
    required this.gradient2,
    required this.buttonColor,
    required this.iconColor,
    required this.filePath,
    required this.imagePath,
    required this.showInfo,
    required this.downloadFile,
    required this.shareFile,
  });

  // Define the file type
  String getFileType(String p_path) {
    File file = File(p_path);
    String? mimeType = lookupMimeType(file.path);
    if (mimeType == 'application/pdf') {
      return "PDF";
    } else if (mimeType == 'application/vnd.ms-excel' || mimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      return "EXCEL";
    } else if (mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return "WORD";
    } else {
      return "UNKNOWN"; // UNKNOWN TYPES (SUPPORTED TYPES ARE EXPANDABLE)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient1, gradient2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        height: 100,
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(imagePath, width: 50, height: 50),
                const SizedBox(height: 5),
                Text(getFileType(filePath), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  Text(
                    filePath.split('/').last,
                    textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                  const SizedBox(height: 10),
                  // Butonlar
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Butonlar ortalanacak
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        onPressed: () => showInfo(),
                        child: Icon(Icons.info, color: iconColor),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        onPressed: () => downloadFile(),
                        child: Icon(Icons.download, color: iconColor),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        onPressed: () => shareFile(),
                        child: Icon(Icons.share, color: iconColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
