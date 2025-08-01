import '../../Components/CustomDrawer.dart';
import 'AdminCompaniesPage.dart';
import '../User/TaxCalculator.dart';
import '../Admin/AdminUpdatePage.dart';
import 'PremiumUpgradePage.dart';
import 'package:flutter/material.dart';
import '../../../Services/Database/DatabaseHelper.dart';
import 'ArchivedCompaniesPage.dart';

class CompanyConfirmPage extends StatefulWidget {
  final String adminID;

  const CompanyConfirmPage({super.key, required this.adminID});

  @override
  State<CompanyConfirmPage> createState() => _CompanyConfirmPageState();
}

class _CompanyConfirmPageState extends State<CompanyConfirmPage> {
  List<Map<String, dynamic>> pendingCompanies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingCompanies();
  }

  Future<void> fetchPendingCompanies() async {
    final companies = await DatabaseHelper().getPendingCompanies(widget.adminID);
    final filteredCompanies = companies.where((company) =>
      company['companyAdmin'] == widget.adminID && (company['confirmed'] == null)
    ).toList();

    setState(() {
      pendingCompanies = filteredCompanies;
      isLoading = false;
    });
  }

  Future<void> confirmCompany(String companyID) async {
    await DatabaseHelper().confirmCompany(companyID);
    fetchPendingCompanies();
  }

  Future<void> rejectCompany(String companyID) async {
    await DatabaseHelper().rejectCompany(companyID);
    fetchPendingCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text("Müvekkil Onayı", 
        style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),
        ),
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ArchivedCompaniesPage(adminID: widget.adminID),
            ),
          );
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
        page: 6,
      ),
      backgroundColor: const Color(0xFFAAB6C8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: const Color(0xFFAAB6C8),
              child: pendingCompanies.isEmpty
                  ? const Center(
                      child: Text(
                        "Bekleyen müvekkil yok.",
                        style: TextStyle(color: Color(0xFF1A1A1A)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: pendingCompanies.length,
                      itemBuilder: (context, index) {
                        final company = pendingCompanies[index];
                        return Card(
                          color: const Color(0xFF3D5A80),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            title: Text(
                              company['companyName'] ?? "Bilinmeyen",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEFEFEF)),
                            ),
                            subtitle: Text(
                              "ID: ${company['companyID']}",
                              style: const TextStyle(color: Color(0xFFEFEFEF)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outlined, color: Colors.green, size: 28),
                                  onPressed: () async {
                                    final shouldConfirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Onayla', style: TextStyle(color: Color(0xFFEFEFEF))),
                                        content: const Text('Bu müvekkili onaylamak istediğinize emin misiniz?', style: TextStyle(color: Color(0xFFEFEFEF))),
                                        backgroundColor: const Color(0xFF3D5A80),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('İptal', style: TextStyle(color: Color(0xFFEFEFEF))),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1E3A5F),
                                            ),
                                            child: const Text('Onayla', style: TextStyle(color: Color(0xFFEFEFEF))),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (shouldConfirm == true) {
                                      await confirmCompany(company['companyID']);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel_outlined, color: Color.fromARGB(255, 213, 60, 49), size: 28),
                                  onPressed: () async {
                                    final shouldReject = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Reddet', style: TextStyle(color: Color(0xFFEFEFEF))),
                                        content: const Text('Bu müvekkili reddetmek istediğinize emin misiniz?', style: TextStyle(color: Color(0xFFEFEFEF))),
                                        backgroundColor: const Color(0xFF3D5A80),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('İptal', style: TextStyle(color: Color(0xFFEFEFEF))),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1E3A5F),
                                            ),
                                            child: const Text('Reddet', style: TextStyle(color: Color(0xFFEFEFEF))),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (shouldReject == true) {
                                      await rejectCompany(company['companyID']);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}