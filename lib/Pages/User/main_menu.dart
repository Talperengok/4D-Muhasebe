import 'package:direct_accounting/Pages/User/FileViewPage.dart';
import 'package:flutter/material.dart';

import '../../Components/MainMenuButton.dart';

class MainMenu extends StatelessWidget {
  final List<Map<String, dynamic>> teamInfo;
  final String currentUserId;

  const MainMenu({
    Key? key,
    required this.teamInfo,
    required this.currentUserId,
  }) : super(key: key);

  // Fonksiyonlar
  Future<void> onPersonelFilesClicked(BuildContext context) async {
    List<Map<String, dynamic>> docs =  [
      {
       "filePath" : "content://com.android.providers.downloads.documents/document/msf%3A1000000043",
       "fileCreated" : DateTime.now().add(Duration(days: -3)),
       "fileDownloaded" : DateTime.now,
       "fileOwnerClient" : "ABK LTD.",
       "fileUploadedBy" : "Admin"
      }
      ,
      {
        "filePath" : "content://com.android.providers.downloads.documents/document/msf%3A1000000044",
        "fileCreated" : DateTime.now().add(Duration(days: -3)),
        "fileDownloaded" : DateTime.now,
        "fileOwnerClient" : "ABK LTD.",
        "fileUploadedBy" : "Admin"
      }
    ];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FileViewPage(documents: docs, title: "Özlük Dosyaları", imagePath: "assets/images/personel_logo.png")),
    );
    print("Özlük Dosyaları tıklandı");
  }

  void onDeclerationsClicked() {
    print("Beyannameler tıklandı");
  }

  void onInsurancesClicked() {
    print("Sigorta Dosyaları tıklandı");
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
    final String displayName = teamInfo.isNotEmpty ? teamInfo[0]['name'] ??
        'Bilinmiyor' : 'Bilinmiyor';

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
                      onDeclerationsClicked();
                    } else if (button['title'] == 'Sigorta Dosyaları') {
                      onInsurancesClicked();
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
                      onDeclerationsClicked();
                    } else if (button['title'] == 'Sigorta Dosyaları') {
                      onInsurancesClicked();
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
