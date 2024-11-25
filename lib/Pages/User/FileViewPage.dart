import 'package:direct_accounting/Components/FileCard.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class FileViewPage extends StatefulWidget {
  final List<Map<String, dynamic>> documents;
  final String title;
  final String imagePath;

  const FileViewPage({
    required this.documents,
    required this.title,
    required this.imagePath,
    Key? key,
  }) : super(key: key);

  @override
  _FileViewPageState createState() => _FileViewPageState();
}

class _FileViewPageState extends State<FileViewPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    bool isMobile = width < 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF080F2B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          slivers: [
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final doc = widget.documents[index];
                  return FileCard(
                    gradient1: const Color(0xFF474878),
                    gradient2: const Color(0xFF325477),
                    buttonColor: Colors.black,
                    iconColor: Colors.white,
                    filePath: doc["filePath"],
                    imagePath: widget.imagePath,
                    showInfo: () {
                      showInfo(doc);
                    },
                    downloadFile: () {
                      downloadFile(doc);
                    },
                    shareFile: () {
                      shareFile(doc);
                    },
                  );
                },
                childCount: widget.documents.length,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF908EC0),
    );
  }

  void showInfo(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Info'),
        content: const Text('TODO: Display file information.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void downloadFile(Map<String, dynamic> document) {
    // TODO: Backend logic to download file
  }

  void shareFile(Map<String, dynamic> document) {
    // TODO: Download file logic before sharing
    print("GİRDİM ABE");
    Share.share(document["filePath"]);
  }
}
