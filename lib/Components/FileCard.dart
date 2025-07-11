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
  final VoidCallback? deleteFile;// Delete File Function (Optional)

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
    this.deleteFile,
  });

  // Define the file type
  String getFileType(String p_path) {
  File file = File(p_path);
  String? mimeType = lookupMimeType(file.path);

  switch (mimeType) {
    case 'application/pdf':
      return "PDF";
    case 'application/msword':
    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      return "WORD";
    case 'application/vnd.ms-excel':
    case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      return "EXCEL";
    case 'image/png':
      return "PNG";
    case 'image/jpeg':
      return "JPEG";
    case 'image/jpg':
      return "JPG";
    case 'text/plain':
      return "TXT";
    case 'application/zip':
      return "ZIP";
    case 'application/x-rar-compressed':
      return "RAR";
    default:
      return mimeType?.toUpperCase().split("/").last ?? "UNKNOWN";
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
                Text(
                  getFileType(filePath),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(width: 10),

            /// Dosya adı ve butonlar
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Tooltip(
                    message: filePath.split('/').last,
                    child: Text(
                      filePath.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        onPressed: () => showInfo(),
                        child: Icon(Icons.info, color: iconColor),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        onPressed: () => downloadFile(),
                        child: Icon(Icons.download, color: iconColor),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        onPressed: () => shareFile(),
                        child: Icon(Icons.share, color: iconColor),
                      ),
                      if (deleteFile != null) ...[
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                          ),
                          onPressed: deleteFile,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                      ],
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
