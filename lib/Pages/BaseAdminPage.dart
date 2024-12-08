import 'package:direct_accounting/Services/Database/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AdminPanelPage extends StatefulWidget {
  // Burada panel admin'in sabit kullanıcı adı ve şifresi:
  final String panelAdminUser = "panelAdmin";
  final String panelAdminPass = "panel123";

  // Bu örnekte panel sayfası doğrudan açılıyor, ama normalde bir login ekranı ile kontrol edebilirsiniz.

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> admins = [];
  bool loading = false;

  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    setState(() {
      loading = true;
    });
    var list = await dbHelper.getAdmins();
    setState(() {
      admins = list;
      loading = false;
    });
  }

  Future<void> createAdmin() async {
    if (_adminNameController.text.isEmpty || _adminPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen isim ve şifre giriniz")),
      );
      return;
    }

    // expiry date = şimdi + 30 gün
    DateTime expiryDate = DateTime.now().add(Duration(days: 30));
    String expiryDateStr = DateFormat('yyyy-MM-dd').format(expiryDate);

    var result = await dbHelper.createAdmin(
      _adminNameController.text,
      "", // adminCompanies boş string
      expiryDateStr,
      _adminPasswordController.text,
      "", // adminFiles boş string
      "", // adminMessages boş string
    );
    print(result);

    if (result.contains("success")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Admin başarıyla oluşturuldu")),
      );
      _adminNameController.clear();
      _adminPasswordController.clear();
      fetchAdmins();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Admin oluşturulamadı")),
      );
    }
  }

  Future<void> deleteAdmin(String adminID) async {
    /*var result = await dbHelper.deleteAdmin(adminID);
    if (result.contains("success")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Admin başarıyla silindi")),
      );
      fetchAdmins();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Admin silinemedi")),
      );
    }
     */
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Paneli',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF080F2B),
      ),
      backgroundColor: Color(0xFF908EC0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isMobile
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Admin Yönetimi",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 16),
            // Admin Ekleme Formu
            TextField(
              controller: _adminNameController,
              decoration: InputDecoration(
                labelText: "Admin Name",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _adminPasswordController,
              decoration: InputDecoration(
                labelText: "Admin Password",
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF080F2B)),
              onPressed: createAdmin,
              child: Text("Admin Oluştur"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  var admin = admins[index];
                  return Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("UID: ${admin['adminID']}", style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: 5,),
                              IconButton(
                                  onPressed: (){
                                    Clipboard.setData(ClipboardData(text: admin['adminID']));
                                  },
                                  icon: Icon(Icons.copy)
                              )
                            ],
                          ),
                          SizedBox(height: 2,),
                          Text("Name: ${admin['adminName']}"),
                        ],
                      ),
                      subtitle: Text("Expiry: ${admin['adminExpiryDate']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteAdmin(admin['adminID'].toString()),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        )
            : Center(
          child: Container(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Yönetimi",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _adminNameController,
                  decoration: InputDecoration(
                    labelText: "Admin Name",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _adminPasswordController,
                  decoration: InputDecoration(
                    labelText: "Admin Password",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF080F2B)),
                  onPressed: createAdmin,
                  child: Text("Admin Oluştur"),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: loading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: admins.length,
                    itemBuilder: (context, index) {
                      var admin = admins[index];
                      return Card(
                        child: ListTile(
                          title: Column(
                            children: [
                              Row(
                                children: [
                                  Text("UID: ${admin['adminID']}", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: 5,),
                                  IconButton(
                                      onPressed: (){
                                        Clipboard.setData(ClipboardData(text: admin['adminID']));
                                      },
                                      icon: Icon(Icons.copy)
                                  )
                                ],
                              ),
                              SizedBox(height: 2,),
                              Text("Name: ${admin['adminName']}"),
                            ],
                          ),
                          subtitle: Text("Expiry: ${admin['adminExpiryDate']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteAdmin(admin['adminID'].toString()),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
