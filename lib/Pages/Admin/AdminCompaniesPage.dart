import 'package:direct_accounting/Pages/Admin/ArchivedCompaniesPage.dart';
import 'package:direct_accounting/Pages/User/ChatPage.dart';
import 'package:direct_accounting/Pages/User/LoginPage.dart';
import 'package:direct_accounting/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../User/TaxCalculator.dart';
import '../../Components/CompanyCard.dart';
import '../../Components/CustomDrawer.dart';
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
  final GlobalKey _menuKey = GlobalKey();
  final DatabaseHelper dbHelper = DatabaseHelper(); // Backend işlemleri için

  Map<String, dynamic> adminData = {}; // Muhasebeci bilgileri
  List<Map<String, dynamic>> companies = []; // Müvekkiller
  bool loading = false; // Veri yükleniyor mu?

  int currentPage = 0; // Şu anki sayfa
  final int itemsPerPage = 10; // Sayfa başına eleman sayısı

  String searchQuery = ""; // Arama sorgusu

  List<String> notifications = [];

  int visibleNotificationCount = 6;

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

      final allCompanies = await dbHelper.getActiveCompanies();
      List<Map<String, dynamic>> filteredCompanies = allCompanies
          .where((company) => company['companyAdmin'] == widget.adminID)
          .toList();

      int prevCompaniesLength = companies.length;
      List<Map<String, dynamic>> previousCompanies = List.from(companies);

      setState(() {
        adminData = adminDetails;
        companies = filteredCompanies;
        currentPage = 0;
        loading = false;
      });

      if (filteredCompanies.length > prevCompaniesLength) {
        // Find which companies are new and add a notification for each
        final newCompanies = filteredCompanies.where((c) => !previousCompanies.any((p) => p['companyID'] == c['companyID'])).toList();
        for (var newCompany in newCompanies) {
          notifications.insert(0, "Yeni müvekkil eklendi: ${newCompany['companyName']}");
        }
      }
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

  void _openFileRequestDialog() {
    List<String> selectedFiles = [];
    List<String> availableFiles = [
      "Kimlik Fotokopisi",
      "Vergi Levhası",
      "Faaliyet Belgesi",
      "İmza Sirküleri",
      "Ticaret Sicil Gazetesi"
    ];

    String? selectedClientID;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Dosya Talebi Oluştur"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Müvekkil Seç",
                        border: OutlineInputBorder(),
                      ),
                      items: filteredCompanies.map((company) {
                        return DropdownMenuItem<String>(
                          value: company['companyID'],
                          child: Text(company['companyName']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedClientID = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ...availableFiles.map((fileType) {
                      return CheckboxListTile(
                        title: Text(fileType),
                        value: selectedFiles.contains(fileType),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedFiles.add(fileType);
                            } else {
                              selectedFiles.remove(fileType);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedClientID != null && selectedFiles.isNotEmpty) {
                  try {
                    await DatabaseHelper().sendFileRequest(
                      adminID: widget.adminID,
                      companyID: selectedClientID!,
                      requestedFiles: selectedFiles,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Dosya talebi gönderildi.")),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gönderim hatası: $e")),
                    );
                  }
                }
              },
              child: const Text("Gönder"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> archiveClient(Map<String, dynamic> company) async {
  bool confirmed = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Müvekkili Arşivle"),
      content: const Text("Bu müvekkil arşivlenecek ve listeden gizlenecek. Devam edilsin mi?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Evet")),
      ],
    ),
  );

  if (confirmed) {
    await DatabaseHelper().updateCompanyArchiveStatus(company["companyID"], true);
    await getAdminData(); // listeyi güncelle
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
                    "kayıt olunuz:\n\nMuhasebeci Sicil No: ${adminData["adminID"]}\nMuhasebeci Eşsiz Kimlik: ${adminData["UID"]}";

                Clipboard.setData(ClipboardData(text: mess));

                // Bilgilendirme mesajı
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Muhasebeci bilgileri kopyalandı."),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF080F2B),
              ),
              child: const Text("Muhasebeci Bilgilerini Kopyala"),
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
      drawer: AdminDrawer(
        page: 1,
        onButton1Pressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminCompaniesPage(adminID: widget.adminID),
            ),
          );
        },
        onButton2Pressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaxCalculationPage(
                companyId: widget.adminID,
                isAdmin: true,
              ),
            ),
          );
        },
        onButton3Pressed: () async {
          Navigator.pop(context);
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArchivedCompaniesPage(adminID: widget.adminID)),
          );
          await getAdminData(); // refresh on return
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
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFEFEFEF)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'Muhasebeci Paneli',
          style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1B2A),
        actions: [
          IconButton(
            onPressed: _openFileRequestDialog,
            icon: const Icon(Icons.sim_card_download_outlined, color: Colors.greenAccent),
          ),
          Builder(
            builder: (context) {
              return PopupMenuButton<String>(
                key: _menuKey,
                icon: const Icon(Icons.notifications, color: Colors.orangeAccent),
                tooltip: 'Bildirimler',
                offset: const Offset(100, kToolbarHeight),
                itemBuilder: (context) {
                  List<String> visibleNotifications = notifications.take(visibleNotificationCount).toList();

                  List<PopupMenuEntry<String>> items = visibleNotifications.map((note) {
                    return PopupMenuItem<String>(
                      value: note,
                      child: Text(note),
                    );
                  }).toList();

                  if (visibleNotificationCount < notifications.length) {
                    items.add(
                      PopupMenuItem<String>(
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
                  } else if (notifications.length > 6) {
                    items.add(
                      PopupMenuItem<String>(
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
                Expanded(
                  child: companies.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                          child: Text(
                            "Henüz aktif müvekkiliniz bulunmuyor.\nMüvekkil eklemek için sağ alttaki + butonuna tıklayın.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : filteredCompanies.isEmpty
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
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                      child: CompanyCard(
                                        companyData: company,
                                        gradient1: const Color(0xFF3D5A80),
                                        gradient2: const Color(0xFF2E4A66),
                                        buttonColor: const Color(0xFF1E3A5F),
                                        iconColor: const Color(0xFFEFEFEF),
                                        showDetails: () => showDetails(company),
                                        sendMessage: () => sendMessage(company['companyID'].toString()),
                                        showFiles: () => showFiles(company),
                                        archiveClient: () => archiveClient(company),
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
        child: const Icon(Icons.add, color: Color((0xFFEFEFEF))),
      ),
    );
  }
}
