import 'dart:io';

import 'package:direct_accounting/Pages/User/FileViewPage.dart';
import 'package:direct_accounting/Services/Database/DatabaseHelper.dart';
import 'package:direct_accounting/widget/loading_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Components/MainMenuButton.dart';

class MainMenu extends StatelessWidget {
  final Map<String, dynamic> teamInfo;
  final String currentUserId;
  final bool isAdmin;

  const MainMenu({
    Key? key,
    required this.teamInfo,
    required this.currentUserId,
    required this.isAdmin,
  }) : super(key: key);

  // Fonksiyonlar
  Future<void> onPersonelFilesClicked(BuildContext context) async {
    /*FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    print(result!.paths);
     */
    List<Map<String, dynamic>> docs = [];
    LoadingIndicator(context).showLoading();
    List<String> fileIds = teamInfo["companyFiles"].toString() != ""
        ? teamInfo["companyFiles"].toString().split(",")
        : [];
    for (String file in fileIds) {
      Map<String, dynamic>? fileMap = await DatabaseHelper().getFile(file);
      if (fileMap != null && fileMap["fileType"] == "personel") {
        docs.add(fileMap);
      }
    }
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          FileViewPage(
            documents: docs,
            title: "Özlük Dosyaları",
            imagePath: "assets/images/personel_logo.png",
            currentUser: currentUserId,
            companyId: teamInfo["companyID"],
            companyAdmin: teamInfo["companyAdmin"],
          )
      ),
    );
  }

  Future<void> onDeclerationsClicked(BuildContext context) async {
    List<Map<String, dynamic>> docs = [];
    LoadingIndicator(context).showLoading();
    List<String> fileIds = teamInfo["companyFiles"].toString() != ""
        ? teamInfo["companyFiles"].toString().split(",")
        : [];
    for (String file in fileIds) {
      Map<String, dynamic>? fileMap = await DatabaseHelper().getFile(file);
      if (fileMap != null && fileMap["fileType"] == "decleration") {
        docs.add(fileMap);
      }
    }
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          FileViewPage(
            documents: docs,
            title: "Beyannameler",
            imagePath: "assets/images/beyanname.png",
            currentUser: currentUserId,
            companyId: teamInfo["companyID"],
            companyAdmin: teamInfo["companyAdmin"],
          )
      ),
    );
  }

  Future<void> onInsurancesClicked(BuildContext context) async {
    List<Map<String, dynamic>> docs = [];
    LoadingIndicator(context).showLoading();
    List<String> fileIds = teamInfo["companyFiles"].toString() != ""
        ? teamInfo["companyFiles"].toString().split(",")
        : [];
    for (String file in fileIds) {
      Map<String, dynamic>? fileMap = await DatabaseHelper().getFile(file);
      if (fileMap != null && fileMap["fileType"] == "insurance") {
        docs.add(fileMap);
      }
    }
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          FileViewPage(
            documents: docs,
            title: "Sigorta Dosyaları",
            imagePath: "assets/images/sigorta.png",
            currentUser: currentUserId,
            companyId: teamInfo["companyID"],
            companyAdmin: teamInfo["companyAdmin"],
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery'den genişlik değeri alınıyor
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final bool isMobile = screenWidth < 800;

    // Text için veriyi alıyoruz
    final String displayName = teamInfo.isNotEmpty
        ? teamInfo['companyName'] ??
        'Bilinmiyor'
        : 'Bilinmiyor';

    // MainMenuButton listesi
    final List<Map<String, String>> buttons = [
      {
        'title': 'Özlük Dosyaları',
        'informerText': 'Dosyaları Görmek İçin Tıkla',
        'imagePath': 'assets/images/personel_logo.png',
      },
      {
        'title': 'Beyannameler',
        'informerText': 'Dosyaları Görmek İçin Tıkla',
        'imagePath': 'assets/images/beyanname.png',
      },
      {
        'title': 'Sigorta Dosyaları',
        'informerText': 'Dosyaları Görmek İçin Tıkla',
        'imagePath': 'assets/images/sigorta.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direkt Muhasebe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color(0xFF080F2B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isMobile
            ? Column(
          children: [
            Text(displayName, style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),),
            const SizedBox(height: 16),
            ...buttons.map((button) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MainMenuButton(
                  title: button['title']!,
                  informerText: button['informerText']!,
                  imagePath: button['imagePath']!,
                  onPressed: () {
                    if (button['title'] == 'Özlük Dosyaları') {
                      onPersonelFilesClicked(context);
                    } else if (button['title'] == 'Beyannameler') {
                      onDeclerationsClicked(context);
                    } else if (button['title'] == 'Sigorta Dosyaları') {
                      onInsurancesClicked(context);
                    }
                  },
                  gradient1: Color(0xFF474878),
                  gradient2: Color(0xFF325477),
                  height: screenHeight / 3 - 100,
                  width: screenWidth - 20,
                ),
              );
            }).toList(),
          ],
        )
            : Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(displayName, style: Theme
                    .of(context)
                    .textTheme
                    .headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buttons.map((button) {
                return MainMenuButton(
                  title: button['title']!,
                  informerText: button['informerText']!,
                  imagePath: button['imagePath']!,
                  onPressed: () {
                    if (button['title'] == 'Özlük Dosyaları') {
                      onPersonelFilesClicked(context);
                    } else if (button['title'] == 'Beyannameler') {
                      onDeclerationsClicked(context);
                    } else if (button['title'] == 'Sigorta Dosyaları') {
                      onInsurancesClicked(context);
                    }
                  },
                  gradient1: Color(0xFF305476),
                  gradient2: Color(0xFF474878),
                  height: 200,
                  width: 200,
                );
              }).toList(),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF908EC0),
    );
  }
}
