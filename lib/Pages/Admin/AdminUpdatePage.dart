import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Services/Database/DatabaseHelper.dart';
import '../../widget/loading_indicator.dart';
import '../../Components/CustomDrawer.dart';
import 'PremiumUpgradePage.dart';
import 'AdminCompaniesPage.dart';
import 'ArchivedCompaniesPage.dart';
import '../User/TaxCalculator.dart';
import 'CompanyConfirmPage.dart';

/// SETTINGS PAGE FOR ADMINS

class AdminUpdatePage extends StatefulWidget {
  final String adminID; // WHICH ADMIN?

  const AdminUpdatePage({Key? key, required this.adminID}) : super(key: key);

  @override
  State<AdminUpdatePage> createState() => _AdminUpdatePageState();
}

class _AdminUpdatePageState extends State<AdminUpdatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  Map<String, dynamic> adminDetails = {}; // CURRENT ADMIN DETAILS
  bool _isLoading = true;
  bool _isPasswordChanging = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchAdminDetails();
  }

  // GETS ADMIN DETAILS FROM SERVER
  Future<void> _fetchAdminDetails() async {
    setState(() {
      _isLoading = true;
    });
    adminDetails = (await DatabaseHelper().getAdminDetails(widget.adminID))!;
    _nameController.text = adminDetails['adminName'] ?? '';
    setState(() {
      _isLoading = false;
    });
  }

  // SAVES THE CHANGES
  Future<void> _saveChanges() async {
    LoadingIndicator(context).showLoading();
    String result = await DatabaseHelper().updateAdminDetails(
      widget.adminID,
      _nameController.text.trim(),
      adminDetails["adminPassword"],
    );
    Navigator.pop(context);

    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin bilgileri başarıyla güncellendi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgiler güncellenirken bir hata oluştu.')),
      );
    }
  }

  // CHANGE ADMIN PASSWORD
  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    LoadingIndicator(context).showLoading();
    var authResult = await DatabaseHelper().authenticateUser(
      'Admin',
      widget.adminID,
      _oldPasswordController.text.trim(),
    );

    Navigator.pop(context);

    if (authResult == true) {
      LoadingIndicator(context).showLoading();
      String result = await DatabaseHelper().updateAdminDetails(
        widget.adminID,
        _nameController.text.trim(),
        _newPasswordController.text.trim(),
      );
      Navigator.pop(context);

      if (result.contains('success')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifre başarıyla güncellendi.')),
        );
        setState(() {
          _isPasswordChanging = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifre güncellenirken bir hata oluştu.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eski şifre yanlış.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer(
        onButton1Pressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminCompaniesPage(adminID: widget.adminID)),
          );
        },
        onButton2Pressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TaxCalculationPage(companyId: widget.adminID, isAdmin: true),
            ),
          );
        },
        onButton3Pressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ArchivedCompaniesPage(adminID: widget.adminID),
            ),
          );
        },
        onButton4Pressed: () {
          Navigator.pop(context);
          // File request dialog or route
        },
        onButton5Pressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PremiumUpgradePage(adminID: widget.adminID),
            ),
          );
        },
        onButton6Pressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompanyConfirmPage(adminID: widget.adminID),
            ),
          );
        },
        page: 4,
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFFEFEFEF)),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text('Muhasebeci Ayarları',
            style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFAAB6C8),
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
                      labelText: 'Admin Adı',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.admin_panel_settings, color: Color(0xFF1E3A5F)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: widget.adminID),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Admin ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.copy, color: Color(0xFF1E3A5F)),
                    ),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: widget.adminID));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Admin ID kopyalandı.')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_isPasswordChanging) ...[
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Eski Şifre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF1E3A5F)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Yeni Şifre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_open, color: Color(0xFF1E3A5F)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                      ),
                      child: const Text(
                        'Şifreyi Güncelle',
                        style: TextStyle(fontSize: 16, color: Color(0xFFEFEFEF)),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordChanging = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                      ),
                      child: const Text(
                        'Şifreyi Değiştir',
                        style: TextStyle(fontSize: 16, color: Color(0xFFEFEFEF)),
                      ),
                    ),
                  ],
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
