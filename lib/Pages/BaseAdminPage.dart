import 'package:direct_accounting/Services/Database/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///ADMIN PANEL FOR OUR TEAM - JUST 4 PERSONS CAN ACCESS IT
class AdminPanelPage extends StatefulWidget {
  /*final String panelAdminUser = "panelAdmin";
  final String panelAdminPass = "panel123";
   */

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> admins = [];
  bool loading = false;

  /*final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
   */

  @override
  void initState() {
    super.initState();
    fetchAdmins();
  }

  //GET ACCOUNTANTS
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

  //DELETE ACCOUNTANTS
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
          style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      backgroundColor: const Color(0xFFAAB6C8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isMobile
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
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
                              Text("Sicil: ${admin['adminID']}", style: const TextStyle(fontWeight: FontWeight.bold),),
                              const SizedBox(width: 5,),
                              IconButton(
                                  onPressed: (){
                                    Clipboard.setData(ClipboardData(text: admin['adminID']));
                                  },
                                  icon: const Icon(Icons.copy)
                              ),
                              const SizedBox(width: 5,),
                              IconButton(
                                  onPressed: () async {
                                    if(admin["confirmed"] == "YES"){
                                      await DatabaseHelper().updateAdminConfirmed(admin['adminID'], false);
                                    }
                                    else{
                                      await DatabaseHelper().updateAdminConfirmed(admin['adminID'], true);
                                    }
                                    fetchAdmins();
                                  },
                                  icon: Icon(admin["confirmed"] == "YES" ? Icons.check_circle : Icons.remove_circle, color: admin["confirmed"] == "YES" ? Colors.green : Colors.red,)
                              )
                            ],
                          ),
                          const SizedBox(height: 2,),
                          Text("İsim: ${admin['adminName']}"),
                        ],
                      ),
                      subtitle: Text("Üyelik Bitiş: ${admin['adminExpiryDate']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
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
                                  Text("UID: ${admin['adminID']}", style: const TextStyle(fontWeight: FontWeight.bold),),
                                  const SizedBox(width: 5,),
                                  IconButton(
                                      onPressed: (){
                                        Clipboard.setData(ClipboardData(text: admin['adminID']));
                                      },
                                      icon: const Icon(Icons.copy)
                                  )
                                ],
                              ),
                              const SizedBox(height: 2,),
                              Text("Name: ${admin['adminName']}"),
                            ],
                          ),
                          subtitle: Text("Expiry: ${admin['adminExpiryDate']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
