import '../../Components/CustomDrawer.dart';
import 'ChatPage.dart';
import 'CompanyDetailsPage.dart';
import 'FileViewPage.dart';
import 'TasksPage.dart';
import 'LoginPage.dart';
import 'TaxCalculator.dart';
import '../../Services/Database/DatabaseHelper.dart';
import '../../widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import '../../Components/MainMenuButton.dart';


///MAIN MENU PAGE - 2ND PAGE FOR ACCOUNTANTS BUT MAIN PAGE OF CLIENTS
class MainMenu extends StatefulWidget {
  final String currentUserId; //VIEWER USER ID
  final bool isAdmin; // IS VIEWER ACCOUNTANT
  final String companyID; //THE CURRENT PAGE'S CLIENT

  const MainMenu({
    Key? key,
    required this.currentUserId,
    required this.isAdmin,
    required this.companyID,
  }) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Map<String, dynamic> teamInfo = {}; //WHICH CLIENT'S PAGE?
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool hasNewMessages = false;
  final GlobalKey _menuKey = GlobalKey();
  int visibleNotificationCount = 6;

  @override
  void initState() {
    super.initState();
    getCompanyInfo();
    loadFileRequestsAndMessages();
  }

  //GETS CLIENT DETAILS
  Future<void> getCompanyInfo() async {
    Map<String, dynamic>? info = await DatabaseHelper().getCompanyDetails(
        widget.companyID);
    if (info != null) {
      setState(() {
        teamInfo = info;
      });
    } else {
      setState(() {
        teamInfo = {};
      });
    }
  }

  //OPEN PERSONEL FILES (ÖZLÜK)
  Future<void> onPersonelFilesClicked(BuildContext context) async {
    List<Map<String, dynamic>> docs = [];
    LoadingIndicator(context).showLoading();
    List<String> fileIds = teamInfo["companyFiles"].toString() != ""
        ? teamInfo["companyFiles"].toString().split(",")
        : [];
    for (String file in fileIds) {
      Map<String, dynamic>? fileMap = await DatabaseHelper().getFile(file);
      if (fileMap["fileType"] == "personel") {
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
            currentUser: widget.currentUserId,
            companyId: teamInfo["companyID"],
            companyAdmin: teamInfo["companyAdmin"],
          )
      ),
    ).then((_) async {
      await getCompanyInfo();
    });
  }

  //OPEN DECLARATION FILES (BEYANNAME)
  Future<void> onDeclerationsClicked(BuildContext context) async {
    List<Map<String, dynamic>> docs = [];
    LoadingIndicator(context).showLoading();
    List<String> fileIds = teamInfo["companyFiles"].toString() != ""
        ? teamInfo["companyFiles"].toString().split(",")
        : [];
    for (String file in fileIds) {
      Map<String, dynamic>? fileMap = await DatabaseHelper().getFile(file);
      if (fileMap["fileType"] == "decleration") {
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
            currentUser: widget.currentUserId,
            companyId: teamInfo["companyID"],
            companyAdmin: teamInfo["companyAdmin"],
          )
      ),
    ).then((_) async {
      await getCompanyInfo();
    });
  }

  //OPEN INSURANCE FILES (SIGORTA)
  Future<void> onInsurancesClicked(BuildContext context) async {
    List<Map<String, dynamic>> docs = [];
    LoadingIndicator(context).showLoading();
    List<String> fileIds = teamInfo["companyFiles"].toString() != ""
        ? teamInfo["companyFiles"].toString().split(",")
        : [];
    for (String file in fileIds) {
      Map<String, dynamic>? fileMap = await DatabaseHelper().getFile(file);
      if (fileMap["fileType"] == "insurance") {
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
            currentUser: widget.currentUserId,
            companyId: teamInfo["companyID"],
            companyAdmin: teamInfo["companyAdmin"],
          )
      ),
    ).then((_) async {
      await getCompanyInfo();
    });
  }

  //File_Requests
  List<Map<String, dynamic>> fileRequests = [];

  Future<void> loadFileRequestsAndMessages() async {
    List<Map<String, dynamic>> requests = await DatabaseHelper().getFileRequestsForCompany(widget.companyID);
    bool newMessagesExist = await DatabaseHelper().hasUnreadMessagesFromAccountant(widget.companyID);

    setState(() {
      fileRequests = requests;
      hasNewMessages = newMessagesExist;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final bool isMobile = screenWidth < 800; //GET SCREEN WIDTH AND DECIDE MOBILE OR DESKTOP LAYOUT

    final String displayName = teamInfo.isNotEmpty
        ? (teamInfo['companyName'] ?? 'Bilinmiyor')
        : 'Bilinmiyor';

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
      key: _scaffoldKey,
      appBar: AppBar(
        leading: widget.isAdmin
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFEFEFEF)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFFEFEFEF)),
                    onPressed: () {
                      _scaffoldKey.currentState!.openDrawer();
                    },
                  );
                },
              ),
        title: const Text('Müvekkil Paneli',
          style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: [
          if (!widget.isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.upload_file, color: Colors.greenAccent),
              tooltip: 'Görevler',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TasksDialog(companyId: widget.companyID),
                );
              },
            ),
            Builder(
              builder: (context) {
                return PopupMenuButton<int>(
                  key: _menuKey,
                  icon: Icon(
                    Icons.notifications,
                    color: hasNewMessages ? Colors.redAccent : Colors.amberAccent,
                  ),
                  tooltip: 'Bildirimler',
                  offset: const Offset(100, kToolbarHeight),
                  itemBuilder: (BuildContext context) {
                    final latestRequests = fileRequests.take(visibleNotificationCount).toList();
                    List<PopupMenuEntry<int>> items = [];

                    if (hasNewMessages) {
                      items.add(
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text(
                            'Yeni mesajınız var.',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      );
                    }

                    if (latestRequests.isEmpty && !hasNewMessages) {
                      items.add(
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text("Bildirim yok"),
                        ),
                      );
                    } else {
                      items.addAll(
                        List<PopupMenuEntry<int>>.generate(
                          latestRequests.length,
                          (index) => const PopupMenuItem<int>(
                            value: 2,
                            child: Text(
                              'Yeni dosya talebi var.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    }

                    if (visibleNotificationCount < fileRequests.length) {
                      items.add(
                        PopupMenuItem<int>(
                          enabled: false,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                visibleNotificationCount += 6;
                              });
                              Future.delayed(const Duration(milliseconds: 100), () {
                                (_menuKey.currentState as PopupMenuButtonState?)?.showButtonMenu();
                              });
                            },
                            child: const Text(
                              'Daha fazla göster...',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    } else if (fileRequests.length > 6) {
                      items.add(
                        PopupMenuItem<int>(
                          enabled: false,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                visibleNotificationCount = 6;
                              });
                              Future.delayed(const Duration(milliseconds: 100), () {
                                (_menuKey.currentState as PopupMenuButtonState?)?.showButtonMenu();
                              });
                            },
                            child: const Text(
                              'Daha az göster...',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }

                    return items;
                  },
                );
              },
            ),
          ],
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      drawer: !widget.isAdmin
          ? ClientDrawer(
              onButton1Pressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainMenu(
                      currentUserId: widget.currentUserId,
                      isAdmin: false,
                      companyID: widget.currentUserId,
                    ),
                  ),
                );
              },
              onButton2Pressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaxCalculationPage(
                      companyId: widget.companyID,
                    ),
                  ),
                );
              },
              onButton3Pressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      currentUserID: widget.currentUserId,
                      companyID: widget.companyID,
                      adminID: teamInfo["companyAdmin"],
                    ),
                  ),
                );
              },
              onButton4Pressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompanyUpdatePage(
                      companyID: widget.companyID,
                    ),
                  ),
                );
              },
              page: 1, // adjust this if needed based on current page context
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isMobile
            ? Column(
          children: [
            Text(displayName, style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
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
                  gradient1: const Color(0xFF3D5A80),
                  gradient2: const Color(0xFF2E4A66),
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
                  gradient1: const Color(0xFF305476),
                  gradient2: const Color(0xFF474878),
                  height: 200,
                  width: 200,
                );
              }).toList(),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFAAB6C8),
    );
  }
}
