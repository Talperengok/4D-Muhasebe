import 'package:direct_accounting/Pages/User/ChatPage.dart';
import 'package:direct_accounting/Pages/User/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Components/CompanyCard.dart';
import '../User/main_menu.dart';
import '../../Services/Database/DatabaseHelper.dart';

///PAGE THAT ACCOUNTANTS SEE THEIR CLIENTS (MAIN PAGE FOR ACCOUNTANT)

class AdminCompaniesPage extends StatefulWidget {
  final String adminID; //Who is viewing the page?

  const AdminCompaniesPage({super.key, required this.adminID});

  @override
  State<AdminCompaniesPage> createState() => _AdminCompaniesPageState();
}

class _AdminCompaniesPageState extends State<AdminCompaniesPage> {
  final DatabaseHelper dbHelper = DatabaseHelper(); // Defined DatabaseHelper class to do backend operations.

  Map<String, dynamic> adminData = {}; //Current viewer accountant's data
  List<Map<String, dynamic>> companies = []; //Accountant's clients
  bool loading = false; //Is Data Loading?

  @override
  void initState() {
    super.initState();
    getAdminData();
  }

  //Function to get Admin Data
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

      //Get clients and select the ones connected with viewer accountant.
      final allCompanies = await dbHelper.getCompanies();
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
      print("Error fetching admin data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin verileri alınırken hata oluştu")),
      );
      setState(() {
        loading = false;
      });
    }
  }

  // Show client details
  void showDetails(Map<String, dynamic> company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Müvekkil Detayları"),
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

  // Redirect to client's File View
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

  // Message to client - Redirects Chat Page
  void sendMessage(String companyID) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          ChatPage(currentUserID: widget.adminID, companyID: companyID, adminID: widget.adminID)
      ),
    );
  }

  // Create Client Dialog
  void openCreateCompanyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Müvekkil Ekle"),
              content: const Text('Müvekkil ekleyebilmek için aşağıdaki "Muhasebeci Bilgilerini Kopyala" butonuna tıklayın'
                  ' ve kopyalanan bilgileri müvekkilinize iletip, o bilgilerle uygulamaya kayıt olmasını isteyin.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    String mess = "Merhabalar, belge paylaşımlarımızı ve iletişimlerimizi "
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
          },
        );
      },
    );
  }

  // Delete Client Function - Not effective yet
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DM - Muhasebeci Paneli',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF080F2B),
        leading: IconButton(
          onPressed: (){
            getAdminData();
          },
          icon: Icon(Icons.settings_backup_restore, color: Colors.white,),
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>
                    LoginPage()
                ),
              );
            },
            icon: Icon(Icons.logout, color: Colors.red,),
          )
        ],
      ),
      backgroundColor: const Color(0xFF908EC0),
      body: loading // Check if data is loading, then return widget by company count
          ? const Center(child: CircularProgressIndicator())
          : companies.isEmpty
          ? const Center(
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
                const SizedBox(height: 10,),
                CompanyCard(
                  companyData: company,
                  gradient1: const Color(0xFF474878),
                  gradient2: const Color(0xFF325477),
                  buttonColor: const Color(0xFF080F2B),
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
        backgroundColor: const Color(0xFF080F2B),
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
