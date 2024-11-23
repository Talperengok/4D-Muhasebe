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
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 800;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              crossAxisCount: isMobile ? 1 : 2,
              childAspectRatio: 2.0, // Card'ların en boy oranı
              children: widget.documents.map((doc) => _buildFileCard(doc)).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> document) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
            Image.asset(widget.imagePath, height: 100, fit: BoxFit.cover),
        SizedBox(height: 10),
        Text(
          document['filePath'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // ... Diğer bilgiler (tarih, boyut, vb.)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () => showInfo(document),
            ),
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () => downloadFile(document),
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => shareFile(document),
            ),
          ],
        ),
        ],
      ),
    ),
    );
  }

  void showInfo(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('File Info'),
        content: Text('TODO: Display file information.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))
        ],
      ),
    );
  }

  void downloadFile(Map<String, dynamic> document) {
    // TODO: Backend logic to download file
  }

  void shareFile(Map<String, dynamic> document) {
    // TODO: Download file logic before sharing
    Share.share('TODO: Share file');
  }
}
