import 'package:flutter/material.dart';
import '../../Services/Database/DatabaseHelper.dart';
import 'AdminCompaniesPage.dart';
import '../../Components/CustomDrawer.dart';
import 'AdminUpdatePage.dart';
import '../User/TaxCalculator.dart';
import 'PremiumUpgradePage.dart';
import 'CompanyConfirmPage.dart';

class ArchivedCompaniesPage extends StatefulWidget {
  final String adminID;

  const ArchivedCompaniesPage({Key? key, required this.adminID}) : super(key: key);

  @override
  State<ArchivedCompaniesPage> createState() => _ArchivedCompaniesPageState();
}

class _ArchivedCompaniesPageState extends State<ArchivedCompaniesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = DatabaseHelper();
  List<Map<String, dynamic>> archivedCompanies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArchivedCompanies();
  }

  Future<void> fetchArchivedCompanies() async {
    final companies = await db.getArchivedCompanies();
    setState(() {
      archivedCompanies = companies;
      isLoading = false;
    });
  }

  Future<void> unarchiveCompany(String companyID) async {
    final result = await db.updateCompanyArchiveStatus(companyID, false);
    if (result == 'success') {
      await fetchArchivedCompanies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Müvekkil arşivden çıkarıldı.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("İşlem başarısız: $result")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFFEFEFEF)),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text('Arşivlenmiş Müvekkiller',
            style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),),
          backgroundColor: const Color(0xFF0D1B2A),
          centerTitle: true,
        ),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaxCalculationPage(companyId: widget.adminID, isAdmin: true),
            ),
          );
        },
        onButton3Pressed: () {
          Navigator.pop(context);
          // current page, do nothing or pop drawer
        },
        onButton4Pressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminUpdatePage(adminID: widget.adminID),
            ),
          );
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
        page: 3,
      ),
      backgroundColor: const Color(0xFFAAB6C8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : archivedCompanies.isEmpty
              ? const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top:60.0, left: 20.0, right: 20.0  ),
                    child: Text(
                      "Arşivlenmiş müvekkil yok.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: archivedCompanies.length,
                  itemBuilder: (context, index) {
                    final company = archivedCompanies[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3D5A80), Color(0xFF2E4A66)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          company['companyName'] ?? '',
                          style: const TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "ID: ${company['companyID']}",
                          style: const TextStyle(color: Color(0xFFEFEFEF)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.restore, color: Color(0xFFEFEFEF)),
                          onPressed: () async {
                            final shouldRestore = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Geri Al'),
                                content: const Text('Bu müvekkili arşivden çıkarmak istediğinize emin misiniz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('İptal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E3A5F),
                                    ),
                                    child: const Text('Evet', style: TextStyle(color: Color(0xFFEFEFEF))),
                                  ),
                                ],
                              ),
                            );

                            if (shouldRestore == true) {
                              await unarchiveCompany(company['companyID']);
                            }
                          },
                          tooltip: "Arşivden Çıkar",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}