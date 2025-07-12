import 'package:direct_accounting/Components/CustomDrawer.dart';
import 'package:direct_accounting/Pages/User/ChatPage.dart';
import 'package:direct_accounting/Pages/User/CompanyDetailsPage.dart';
import 'package:direct_accounting/Pages/User/FileViewPage.dart';
import 'package:direct_accounting/Pages/User/LoginPage.dart';
import 'package:direct_accounting/Pages/User/TaxCalculator.dart';
import 'package:direct_accounting/Services/Database/DatabaseHelper.dart';
import 'package:direct_accounting/widget/loading_indicator.dart';
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

  @override
  void initState() {
    super.initState();
    getCompanyInfo();
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back), color: Colors.white,)
            : IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: Icon(Icons.menu), color: Color(0xFFEFEFEF),),
        title: const Text('Direkt Muhasebe',
          style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => 
                LoginPage()
                ),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          )
        ],
        backgroundColor: Color(0xFF0D1B2A),
      ),
      drawer: !widget.isAdmin ? CustomDrawer(
          onButton1Pressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>
                  MainMenu(currentUserId: widget.currentUserId, isAdmin: false, companyID: widget.currentUserId)
              ),
            );
          },
          onButton2Pressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>
                  TaxCalculationPage(companyId: widget.companyID,)
              ),
            );
          },
          onButton3Pressed: () async {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>
                  ChatPage(currentUserID: widget.currentUserId, companyID: widget.companyID, adminID: teamInfo["companyAdmin"])
              ),
            );
          },
          onButton4Pressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>
                  CompanyUpdatePage(companyID: widget.companyID)
              ),
            );
          },
          page: 1,) : null,
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
                  gradient1: Color(0xFF3D5A80),
                  gradient2: Color(0xFF2E4A66),
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
      backgroundColor: Color(0xFFAAB6C8),
    );
  }
}
