import 'package:direct_accounting/Pages/User/ChatPage.dart';
import 'package:direct_accounting/Pages/User/LoginPage.dart';
import 'package:direct_accounting/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Components/CompanyCard.dart';
import '../User/main_menu.dart';
import '../../Services/Database/DatabaseHelper.dart';
import 'package:direct_accounting/Pages/Admin/AdminUpdatePage.dart';

///PAGE THAT ACCOUNTANTS SEE THEIR CLIENTS (MAIN PAGE FOR ACCOUNTANT)

class AdminCompaniesPage extends StatefulWidget {
  final String adminID; //Who is viewing the page?

  const AdminCompaniesPage({super.key, required this.adminID});

  @override
  State<AdminCompaniesPage> createState() => _AdminCompaniesPageState();
}

class _AdminCompaniesPageState extends State<AdminCompaniesPage> {
  final DatabaseHelper dbHelper = DatabaseHelper(); // Backend işlemleri için

  Map<String, dynamic> adminData = {}; // Muhasebeci bilgileri
  List<Map<String, dynamic>> companies = []; // Müvekkiller
  bool loading = false; // Veri yükleniyor mu?

  int currentPage = 0; // Şu anki sayfa
  final int itemsPerPage = 10; // Sayfa başına eleman sayısı

  String searchQuery = ""; // Arama sorgusu

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
      final adminDetails = await dbHelper.getAdminDetails(widget.adminID);
      if (adminDetails == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin bulunamadı")),
        );
        setState(() {
          loading = false;
        });
        return;
      }

      final allCompanies = await dbHelper.getCompanies();
      List<Map<String, dynamic>> filteredCompanies = allCompanies
          .where((company) => company['companyAdmin'] == widget.adminID)
          .toList();

      setState(() {
        adminData = adminDetails;
        companies = filteredCompanies;
        currentPage = 0; // Veri yenilendiğinde sayfa sıfırla
        loading = false;
      });
    } catch (e) {
      print("Error fetching admin data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin verileri alınırken hata oluştu")),
      );
      setState(() {
        loading = false;
      });
    }
  }

  // Arama sorgusuna göre filtrelenmiş liste
  List<Map<String, dynamic>> get filteredCompanies {
    if (searchQuery.isEmpty) return companies;
    return companies.where((company) {
      final name = company['companyName'].toString().toLowerCase();
      final id = company['companyID'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || id.contains(query);
    }).toList();
  }

  // Filtrelenmiş listeden sayfalama yapılmış liste
  List<Map<String, dynamic>> get paginatedCompanies {
    int start = currentPage * itemsPerPage;
    int end = start + itemsPerPage;
    final filtered = filteredCompanies;
    if (start > filtered.length) return [];
    if (end > filtered.length) end = filtered.length;
    return filtered.sublist(start, end);
  }

  // Müvekkil detayları göster
  void showDetails(Map<String, dynamic> company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Müvekkil Detayları"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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

  // Müvekkilin dosyalarına git
  void showFiles(Map<String, dynamic> company) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainMenu(
          isAdmin: true,
          companyID: company["companyID"],
          currentUserId: widget.adminID,
        ),
      ),
    );
  }

  // Mesaj gönder (ChatPage yönlendirme)
  void sendMessage(String companyID) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatPage(
                currentUserID: widget.adminID,
                companyID: companyID,
                adminID: widget.adminID,
              )),
    );
  }
  void deleteFile(Map<String, dynamic> document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dosya Sil"),
        content: Text(
          "Bu dosyayı silmek istediğinizden emin misiniz?\n\n${document["fileName"]}"
        ),
        actions: [
          TextButton(
            child: const Text("Vazgeç"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      LoadingIndicator(context).showLoading();

      final fileID = document["fileID"];
      if (fileID == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz dosya ID.")));
        Navigator.pop(context);
        return;
      }

      await DatabaseHelper().deleteFile(fileID);

      var compDetails = await DatabaseHelper().getCompanyDetails(document["companyID"]);
      var admDetails = await DatabaseHelper().getAdminDetails(document["companyAdmin"]);

      if (compDetails == null || admDetails == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı bilgisi alınamadı.")));
        Navigator.pop(context);
        return;
      }

      List<String> companyFiles = compDetails["companyFiles"]?.toString().split(",") ?? [];
      List<String> adminFiles = admDetails["adminFiles"]?.toString().split(",") ?? [];

      companyFiles.remove(fileID);
      adminFiles.remove(fileID);

      await DatabaseHelper().updateCompanyFiles(document["companyID"], companyFiles.join(","));
      await DatabaseHelper().updateAdminFiles(document["companyAdmin"], adminFiles.join(","));

      Navigator.pop(context); // loading kapat
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dosya silindi.")));

      await getAdminData(); // ekranı yenile
    }
  }

  // Müvekkil silme fonksiyonu
  void deleteClient(Map<String, dynamic> company) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Müvekkil Sil"),
        content: Text(
          "Bu müvekkili silmek istediğinizden emin misiniz?\n\n${company["companyName"]} (${company["companyID"]})"
        ),
        actions: [
          TextButton(
            child: const Text("Vazgeç"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      LoadingIndicator(context).showLoading();

      final companyID = company["companyID"];
      if (companyID == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz müvekkil ID.")));
        return;
      }

      String result = await DatabaseHelper().deleteCompany(companyID);
      Navigator.pop(context); // loading kapat

      if (result == "success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Müvekkil silindi.")));
        await getAdminData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silme işlemi başarısız.")));
      }
    }
  }

  // Müvekkil ekleme dialogu aç
  void openCreateCompanyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Müvekkil Ekle"),
            content: const Text(
                'Müvekkil ekleyebilmek için aşağıdaki "Muhasebeci Bilgilerini Kopyala" butonuna tıklayın ve kopyalanan bilgileri müvekkilinize iletip, o bilgilerle uygulamaya kayıt olmasını isteyin.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("İptal"),
              ),
              ElevatedButton(
                onPressed: () {
                  String mess =
                      "Merhabalar, belge paylaşımlarımızı ve iletişimlerimizi "
                      "tek bir yerden yönetebilmemiz için Direkt Muhasebe uygulamasını indirip aşağıdaki bilgilerle "
                      "kayıt olunuz:\n\nMuhasebeci Sicil No: ${adminData["adminID"]}\nMuhasebeci Benzersiz Kimlik: ${adminData["UID"]}";
                  Clipboard.setData(ClipboardData(text: mess));
                },
                child: const Text("Muhasebeci Bilgilerini Kopyala"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF080F2B),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DM - Muhasebeci Paneli',
          style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1B2A),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminUpdatePage(adminID: widget.adminID),
              ),
            );
          },
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          )
        ],
      ),
      backgroundColor: const Color(0xFFAAB6C8),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 Arama filtresi artık body içinde burada
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Müvekkil ara...',
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                        currentPage = 0;
                      });
                    },
                  ),
                ),
                // 👇 Geri kalan liste
                Expanded(
                  child: filteredCompanies.isEmpty
                      ? const Center(
                          child: Text(
                            "Aramanıza uygun müvekkil bulunamadı",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              ...paginatedCompanies.map((company) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Yanlardan daraltma
                                  child: CompanyCard(
                                    companyData: company,
                                    gradient1: const Color(0xFF3D5A80),
                                    gradient2: const Color(0xFF2E4A66),
                                    buttonColor: const Color(0xFF1E3A5F),
                                    iconColor: const Color(0xFFEFEFEF),
                                    showDetails: () => showDetails(company),
                                    sendMessage: () => sendMessage(company['companyID'].toString()),
                                    showFiles: () => showFiles(company),
                                    deleteClient: () => deleteClient(company),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: currentPage > 0
                                        ? () => setState(() => currentPage--)
                                        : null,
                                    child: const Text("Önceki"),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    onPressed: (currentPage + 1) * itemsPerPage < filteredCompanies.length
                                        ? () => setState(() => currentPage++)
                                        : null,
                                    child: const Text("Sonraki"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateCompanyDialog,
        backgroundColor: const Color(0xFF0D1B2A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
