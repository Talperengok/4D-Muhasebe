import 'package:direct_accounting/Pages/Admin/AdminCompaniesPage.dart';
import 'package:direct_accounting/Pages/User/main_menu.dart';
import 'package:direct_accounting/Services/Database/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {

  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String userType = "Admin";

  TextEditingController idController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUID();
  }

  Future<void> checkUID() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedUid = prefs.getString('uid') ?? '';
    idController.text = savedUid;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giriş Yap',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF080F2B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: ()  {
                    userType = "Admin";
                    setState(() {

                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userType == "Admin" ? Color(0xFF080F2B) : Color(0xFF908EC0),
                  ),
                  child: const Text(
                    'Muhasebeci',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 5,),
                ElevatedButton(
                  onPressed: ()  {
                      userType = "Company";
                      setState(() {

                      });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userType == "Company" ? Color(0xFF080F2B) : Color(0xFF908EC0),
                  ),
                  child: const Text(
                    'Müvekkil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Hoş Geldiniz!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı ID',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              bool auth = await DatabaseHelper().authenticateUser(userType, idController.text, passwordController.text);
              if(auth){
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('uid', idController.text);
                if(userType == "Admin") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        AdminCompaniesPage(adminID: idController.text)
                    ),
                  );
                }
                else if(userType == "Company"){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        MainMenu(companyID: idController.text, currentUserId: idController.text, isAdmin: false)
                    ),
                  );
                }
              }

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF080F2B),
            ),
            child: const Text(
              'Giriş Yap',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF908EC0),
    );
  }
}
