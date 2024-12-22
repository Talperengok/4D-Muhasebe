import 'dart:convert';

import 'package:direct_accounting/Pages/User/ChatPage.dart';
import 'package:flutter/material.dart';
import '../../Components/CompanyCard.dart';
import '../User/main_menu.dart';
import 'package:intl/intl.dart';
import '../../Services/Database/DatabaseHelper.dart'; // Doğru yolu belirleyin

class AdminCompaniesPage extends StatefulWidget {
  final String adminID;

  const AdminCompaniesPage({Key? key, required this.adminID}) : super(key: key);

  @override
  State<AdminCompaniesPage> createState() => _AdminCompaniesPageState();
}

class _AdminCompaniesPageState extends State<AdminCompaniesPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Map<String, dynamic> adminData = {};
  List<Map<String, dynamic>> companies = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getAdminData();
  }

  Future<void> getAdminData() async {
    try {
      setState(() {
        loading = true;
      });
      // Admin detaylarını al
      final adminDetails = await dbHelper.getAdminDetails(widget.adminID);

      if (adminDetails == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Admin bulunamadı")),
        );
        setState(() {
          loading = false;
        });
        return;
      }

      // Şirket kayıtlarını al
      final allCompanies = await dbHelper.getCompanies();

      // Admin'e atanmış şirketleri filtrele
      List<Map<String, dynamic>> filteredCompanies = allCompanies
          .where((company) =>
      company['companyAdmin'] == widget.adminID)
          .toList();

      setState(() {
        adminData = adminDetails;
        companies = filteredCompanies;
        loading = false;
      });
    } catch (e) {
      // Hata durumunda işlem
      print("Error fetching admin data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Admin verileri alınırken hata oluştu")),
      );
      setState(() {
        loading = false;
      });
    }
  }

  // Şirket detaylarını göster
  void showDetails(Map<String, dynamic> company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Müvekkil Detayları"),
        content: Column(
          children: [
            Text("İsim: ${company["companyName"]}"),
            Text("U.S. No: ${company["companyID"]}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void showFiles(Map<String, dynamic> company) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainMenu(
          isAdmin: true, companyID: company["companyID"], currentUserId: widget.adminID,
        ),
      ),
    );
  }

  // Mesaj gönder
  void sendMessage(String companyID) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          ChatPage(currentUserID: widget.adminID, companyID: companyID, adminID: widget.adminID)
      ),
    );
  }

  // Şirket oluşturma dialogunu aç
  void openCreateCompanyDialog() {
    final TextEditingController _companyNameController = TextEditingController();
    final TextEditingController _companyPasswordController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // StatefulBuilder kullanarak dialog içinde setState yapabiliriz
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Şirket Oluştur"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _companyNameController,
                      decoration: InputDecoration(
                        labelText: "Şirket İsmi",
                      ),
                    ),
                    TextField(
                      controller: _companyPasswordController,
                      decoration: InputDecoration(
                        labelText: "Şirket Şifresi",
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String companyName = _companyNameController.text.trim();
                    String companyPassword = _companyPasswordController.text.trim();

                    if (companyName.isEmpty || companyPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lütfen tüm alanları doldurun")),
                      );
                      return;
                    }

                    String result = await dbHelper.createCompany(
                      companyName,
                      widget.adminID,
                      "",
                      companyPassword,
                      ""
                    );

                    if (result.contains("success")) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Şirket başarıyla oluşturuldu")),
                      );
                      Navigator.pop(context);
                      getAdminData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Şirket oluşturulamadı")),
                      );
                    }
                  },
                  child: Text("Oluştur"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF080F2B),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Şirket silme fonksiyonu
 /* Future<void> deleteCompany(String companyID) async {
    var map = <String, dynamic>{
      'action': 'DELETE_COMPANY',
      'companyID': companyID,
    };
    var response = await http.post(Uri.parse(dbHelper.ROOT), body: map);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Şirket başarıyla silindi")),
        );
        getAdminData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Şirket silinemedi")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Şirket silinirken hata oluştu")),
      );
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Direkt Muhasebe - Muhasebeci',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF080F2B),
      ),
      backgroundColor: Color(0xFF908EC0),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : companies.isEmpty
          ? Center(
        child: Text(
          "Hiç şirket eklenmemiş",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children:
          companies.map((company) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10,),
                CompanyCard(
                  companyData: company,
                  gradient1: Color(0xFF474878),
                  gradient2: Color(0xFF325477),
                  buttonColor: Color(0xFF080F2B),
                  iconColor: Colors.white,
                  showDetails: () => showDetails(company),
                  sendMessage: () => sendMessage(company['companyID'].toString()),
                  showFiles: () => showFiles(company),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateCompanyDialog,
        backgroundColor: Color(0xFF080F2B),
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
