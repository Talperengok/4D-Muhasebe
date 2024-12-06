import 'package:flutter/material.dart';
import '../User/main_menu.dart';
//import 'database_helper.dart'; // Database işlemleri için gerekli import(galiba değil)

class AdminCompaniesPage extends StatefulWidget {
  final String adminID;

  const AdminCompaniesPage({Key? key, required this.adminID}) : super(key: key);

  @override
  State<AdminCompaniesPage> createState() => _AdminCompaniesPageState();
}

class _AdminCompaniesPageState extends State<AdminCompaniesPage> {
  Map<String, dynamic> adminData = {};
  List<Map<String, dynamic>> companies = [];

  @override
  void initState() {
    super.initState();
    getAdminData();
  }

  Future<void> getAdminData() async {
    /*try {
      // Admin detaylarını al
      final adminDetails = await DatabaseHelper.getAdminDetails(widget.adminID);

      // Şirket kayıtlarını al
      final allCompanies = await DatabaseHelper.getCompanies();

      // Admin'e atanmış şirketleri filtrele
      List<Map<String, dynamic>> filteredCompanies = allCompanies
          .where((company) =>
          adminDetails['adminCompanies'].contains(company['companyID']))
          .toList();

      setState(() {
        adminData = adminDetails;
        companies = filteredCompanies;
      });
    } catch (e) {
      // Hata durumunda işlem
      print("Error fetching admin data: $e");
    }

     */
  }

  // Şirket detaylarını göster
  void showDetails(String companyID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Company Details"),
        content: Text("Details for company ID: $companyID"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // Şirket dosyalarını göster (MainMenuPage çağrılacak)
  void showFiles(String companyID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainMenu(
          isAdmin: true, teamInfo: [], currentUserId: '',
        ),
      ),
    );
  }

  // Mesaj gönder
  void sendMessage(String companyID) {
    // Henüz doldurulmadı
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Companies"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: companies.map((company) {
            return CompanyCard(
              companyName: company['name'],
              companyID: company['companyID'],
              onShowDetails: showDetails,
              onShowFiles: showFiles,
              onSendMessage: sendMessage,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CompanyCard extends StatelessWidget {
  final String companyName;
  final String companyID;
  final void Function(String) onShowDetails;
  final void Function(String) onShowFiles;
  final void Function(String) onSendMessage;

  const CompanyCard({
    Key? key,
    required this.companyName,
    required this.companyID,
    required this.onShowDetails,
    required this.onShowFiles,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              companyName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => onShowDetails(companyID),
                  child: const Text("Show Details"),
                ),
                ElevatedButton(
                  onPressed: () => onShowFiles(companyID),
                  child: const Text("Show Files"),
                ),
                ElevatedButton(
                  onPressed: () => onSendMessage(companyID),
                  child: const Text("Send Message"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
