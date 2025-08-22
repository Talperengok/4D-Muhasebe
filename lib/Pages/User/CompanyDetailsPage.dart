import '../../Components/CustomDrawer.dart';
import 'ChatPage.dart';
import 'TaxCalculator.dart';
import 'main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Services/Database/DatabaseHelper.dart';
import '../../widget/loading_indicator.dart';

///SETTINGS PAGE FOR CLIENTS

class CompanyUpdatePage extends StatefulWidget {
  final String companyID; //WHICH COMPANY?

  const CompanyUpdatePage({Key? key, required this.companyID}) : super(key: key);

  @override
  State<CompanyUpdatePage> createState() => _CompanyUpdatePageState();
}

class _CompanyUpdatePageState extends State<CompanyUpdatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  Map<String, dynamic> companyDetails = {}; //CURRENT COMPANY DETAILS
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchCompanyDetails();
  }

  //GETS CLIENT DETAILS FROM SERVER
  Future<void> _fetchCompanyDetails() async {
    setState(() {
      _isLoading = true;
    });
    companyDetails = (await DatabaseHelper().getCompanyDetails(widget.companyID.toString()))!;
    _nameController.text = companyDetails['companyName'] ?? '';
    setState(() {
      _isLoading = false;
    });
  }

  //SAVES THE
  Future<void> _saveChanges() async {
    String newName = _nameController.text.trim();
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    if (newPassword.isNotEmpty && oldPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifre için eski şifre gereklidir.')),
      );
      return;
    }

    LoadingIndicator(context).showLoading();
    String result = 'error';
    try {
      if (newPassword.isEmpty) {
        // Sadece isim güncelleniyorsa
        result = await DatabaseHelper().updateCompanyName(widget.companyID, newName);
      } else {
        // Eski şifre doğruysa önce şifreyi güncelle, sonra ismi güncelle
        var authResult = await DatabaseHelper().authenticateUser(
          'Company',
          widget.companyID,
          oldPassword,
        );
        if (authResult == 'success') {
          // Eski şifre doğru, önce şifreyi güncelle
          var passResult = await DatabaseHelper().updateCompanyPassword(widget.companyID, newPassword);
          if (passResult == 'success') {
            // Sonra şirket adını güncelle
            result = await DatabaseHelper().updateCompanyName(widget.companyID, newName);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eski şifre yanlış.')),
          );
          return;
        }
      }

      if (result == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şirket bilgileri başarıyla güncellendi.')),
        );
        _oldPasswordController.clear();
        _newPasswordController.clear();
        await _fetchCompanyDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bilgiler güncellenirken bir hata oluştu.')),
        );
      }
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },

          icon: const Icon(Icons.menu), color: const Color(0xFFEFEFEF),),
        title: const Text('Şirket Ayarları',
          style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),),
        backgroundColor: const Color(0xFF0D1B2A),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFAAB6C8),
      drawer: ClientDrawer(
        onButton1Pressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainMenu(
                currentUserId: widget.companyID,
                isAdmin: false,
                companyID: widget.companyID,
              ),
            ),
          );
        },
        onButton2Pressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TaxCalculationPage(companyId: widget.companyID),
            ),
          );
        },
        onButton3Pressed: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                currentUserID: widget.companyID,
                companyID: widget.companyID,
                adminID: companyDetails["companyAdmin"],
              ),
            ),
          );
        },
        onButton4Pressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyUpdatePage(companyID: widget.companyID),
            ),
          );
        },
        page: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Şirket Adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business, color: Color(0xFF3D5A80)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: widget.companyID),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Şirket ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.copy, color: Color(0xFF3D5A80)),
              ),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: widget.companyID));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Şirket ID kopyalandı.')),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Eski Şifre (Yeni şifre için zorunlu)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Color(0xFF3D5A80)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre (İsteğe bağlı)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_open, color: Color(0xFF3D5A80)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Kaydet',
                  style: TextStyle(fontSize: 16, color: Color(0xFFEFEFEF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
