import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  final List<Map<String, dynamic>> teamInfo;
  final String currentUserId;

  const MainMenu({
    Key? key,
    required this.teamInfo,
    required this.currentUserId,
  }) : super(key: key);

  // Fonksiyonlar
  void onPersonelFilesClicked() {
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    // Text için veriyi alıyoruz
    final String displayName = teamInfo.isNotEmpty ? teamInfo[0]['name'] ?? 'Bilinmiyor' : 'Bilinmiyor';

    // MainMenuButton listesi
    final List<Map<String, String>> buttons = [
      {
        'title': 'Özlük Dosyaları',
        'informerText': 'Dosyaları Görmek İçin Tıkla',
        'imagePath': 'assets/personel_logo.png',
      },
      {
        'title': 'Beyannameler',
        'informerText': 'Dosyaları Görmek İçin Tıkla',
        'imagePath': 'assets/beyanname.png',
      },
      {
        'title': 'Sigorta Dosyaları',
        'informerText': 'Dosyaları Görmek İçin Tıkla',
        'imagePath': 'assets/sigorta.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direkt Muhasebe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isMobile
            ? Column(
          children: [
            Text(displayName, style: Theme.of(context).textTheme.headlineSmall),
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
                      onPersonelFilesClicked();
                    } else if (button['title'] == 'Beyannameler') {
                      onDeclerationsClicked();
                    } else if (button['title'] == 'Sigorta Dosyaları') {
                      onInsurancesClicked();
                    }
                  },
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
                Text(displayName, style: Theme.of(context).textTheme.headlineSmall),
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
                      onPersonelFilesClicked();
                    } else if (button['title'] == 'Beyannameler') {
                      onDeclerationsClicked();
                    } else if (button['title'] == 'Sigorta Dosyaları') {
                      onInsurancesClicked();
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// MainMenuButton Widget
class MainMenuButton extends StatelessWidget {
  final String title;
  final String informerText;
  final String imagePath;
  final VoidCallback onPressed;

  const MainMenuButton({
    Key? key,
    required this.title,
    required this.informerText,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath, width: 50, height: 50),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                informerText,
                style: Theme.of(context).textTheme.bodyMedium, // Güncellenmiş yapı
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
