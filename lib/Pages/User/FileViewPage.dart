import 'package:direct_accounting/Components/FileCard.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    askPermission();
  }

  Future<void> askPermission() async {
    await Permission.manageExternalStorage.request();
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        print("Storage access granted!");
      } else {
        print("Storage access denied!");
      }
    }
    setState(() {

    });
  }

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
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back), color: Colors.white,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          slivers: [
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                childAspectRatio: 3.3,
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
    ///
    ///         "fileName" : "bos_sigorta.pdf",
    //         "filePath" : "/data/user/0/com.westsoftpro.direct_accounting/cache/file_picker/1732566649157/bos_sigorta.pdf",
    //         "fileCreated" : DateTime.now().add(Duration(days: -3)),
    //         "fileDownloaded" : DateTime.now,
    //         "fileOwnerClient" : "ABK LTD.",
    //         "fileUploadedBy" : "Admin"
    ///
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosya Bilgileri'),
        content: Text(
            'Dosya İsmi : ' + document["fileName"].toString() + "\n\n" +
                'Dosya Yolu : ' + document["filePath"].toString() + "\n\n" +
                'Oluşturma Tarihi : ' + formatDateTime(document["fileCreated"]) + "\n\n" +
                'Son İndirme Tarihi : ' + formatDateTime(document["fileDownloaded"]) + "\n\n" +
                'Dosyayı Sahibi : ' + document["fileOwnerClient"].toString() + "\n\n" +
                'Dosyayı Yükleyen : ' + document["fileUploadedBy"].toString() + "\n\n"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
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
    Share.shareXFiles([XFile(document["filePath"])], text: 'Dosya');
  }

  String formatDateTime(dynamic value) {
    if (value is DateTime) {
      return "${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year} - ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";
    } else if (value is String) {
      DateTime dateTime = DateTime.parse(value);
      return "${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else if (value is int) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value);
      return "${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "Geçersiz Tarih";
    }
  }
}
