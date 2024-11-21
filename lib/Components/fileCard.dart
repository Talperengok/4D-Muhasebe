import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  final Color gradient1;
  final Color gradient2;
  final Color buttonColor;
  final Color iconColor;
  final String filePath;
  final String imagePath;
  final Function showInfo;
  final Function downloadFile;
  final Function shareFile;

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

  // Dosya türünü dosya yoluna göre belirleyelim
  String getFileType(String p_path) {
    if (p_path.toLowerCase().endsWith('.pdf')) {
      return "PDF";
    } else if (p_path.toLowerCase().endsWith('.xlsx')) {
      return "EXCEL";
    } else if (p_path.toLowerCase().endsWith('.docx')) {
      return "WORD";
    } else {
      return "UNKNOWN"; // Türü bilinmeyen dosyalar
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
            // Resim kısmı solda olacak
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(imagePath, width: 50, height: 50),
                const SizedBox(
                    height: 5), // Resim ile metin arasına 5px boşluk ekliyoruz
                Text(getFileType(filePath)),
              ],
            ),
            const SizedBox(
                width: 10), // Resim ile metin arasına boşluk ekliyoruz
            // Diğer içerik kısmı sağda olacak
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Column içeriği ortalanacak
                children: [
                  // Dosya adının son kısmını gösteren metin
                  Text(
                    filePath.split('/').last,
                    textAlign: TextAlign.center, // Text ortalanacak
                  ),
                  const SizedBox(
                      height: 10), // Text ile butonlar arasında boşluk
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
                      const SizedBox(width: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        onPressed: () => downloadFile(),
                        child: Icon(Icons.download, color: iconColor),
                      ),
                      const SizedBox(width: 30),
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
