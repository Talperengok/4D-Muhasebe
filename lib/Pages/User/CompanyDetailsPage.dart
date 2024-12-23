import 'package:direct_accounting/Components/CustomDrawer.dart';
import 'package:direct_accounting/Pages/User/ChatPage.dart';
import 'package:direct_accounting/Pages/User/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:direct_accounting/Services/Database/DatabaseHelper.dart';
import 'package:direct_accounting/widget/loading_indicator.dart';

class CompanyUpdatePage extends StatefulWidget {
  final String companyID;

  const CompanyUpdatePage({Key? key, required this.companyID}) : super(key: key);

  @override
  State<CompanyUpdatePage> createState() => _CompanyUpdatePageState();
}

class _CompanyUpdatePageState extends State<CompanyUpdatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  Map<String, dynamic> companyDetails = {};
  bool _isLoading = true;
  bool _isPasswordChanging = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchCompanyDetails();
  }

  Future<void> _fetchCompanyDetails() async {
    setState(() {
      _isLoading = true;
    });
    companyDetails = (await DatabaseHelper().getCompanyDetails(widget.companyID))!;
    if (companyDetails != null) {
      _nameController.text = companyDetails['companyName'] ?? '';
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    LoadingIndicator(context).showLoading();
    String result = await DatabaseHelper().updateCompanyDetails(
      widget.companyID,
      _nameController.text.trim(),
      '', // Şifreyi değiştirmezsek boş gönderiyoruz
    );
    Navigator.pop(context); // Hide loading indicator

    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şirket bilgileri başarıyla güncellendi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilgiler güncellenirken bir hata oluştu.')),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    LoadingIndicator(context).showLoading();

    // Eski şifreyi doğrula
    var authResult = await DatabaseHelper().authenticateUser(
      'Company',
      widget.companyID,
      _oldPasswordController.text.trim(),
    );

    Navigator.pop(context); // Hide loading indicator

    if (authResult == true) {
      // Yeni şifreyi kaydet
      LoadingIndicator(context).showLoading();
      String result = await DatabaseHelper().updateCompanyDetails(
        widget.companyID,
        _nameController.text.trim(),
        _newPasswordController.text.trim(),
      );
      Navigator.pop(context); // Hide loading indicator

      if (result.contains('success')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şifre başarıyla güncellendi.')),
        );
        setState(() {
          _isPasswordChanging = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şifre güncellenirken bir hata oluştu.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eski şifre yanlış.')),
      );
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

          icon: Icon(Icons.menu), color: Colors.white,),
        title: Text('Şirket Ayarları',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFF080F2B),
        centerTitle: true,
      ),
      drawer: CustomDrawer(
        onButton1Pressed: (){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                MainMenu(currentUserId: widget.companyID, isAdmin: false, companyID: widget.companyID)
            ),
          );
        },
        onButton2Pressed: (){

        },
        onButton3Pressed: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                ChatPage(currentUserID: widget.companyID, companyID: widget.companyID, adminID: companyDetails["companyAdmin"])
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
        page: 4,)
      ,body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Şirket Adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business, color: Color(0xFF474878)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: widget.companyID),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Şirket ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.copy, color: Color(0xFF474878)),
              ),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: widget.companyID));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Şirket ID kopyalandı.')),
                );
              },
            ),
            SizedBox(height: 16),
            if (_isPasswordChanging) ...[
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Eski Şifre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF474878)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_open, color: Color(0xFF474878)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF474878),
                ),
                child: Text(
                  'Şifreyi Güncelle',
                  style: TextStyle(fontSize: 16, color: Colors.white),
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
                  backgroundColor: Color(0xFF474878),
                ),
                child: Text(
                  'Şifreyi Değiştir',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF474878),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Kaydet',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
