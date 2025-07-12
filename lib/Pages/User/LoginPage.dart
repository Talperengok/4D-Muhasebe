import 'dart:math';
import 'package:direct_accounting/Pages/Admin/AdminCompaniesPage.dart';
import 'package:direct_accounting/Pages/User/main_menu.dart';
import 'package:direct_accounting/Services/Database/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///LOGIN PAGE
class LoginPage extends StatefulWidget {

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String userType = "Admin"; //DEFINE LOGGING USER

  bool isLogin = true; //DEFINE LOGIN OR SIGNUP PAGE

  TextEditingController idController = TextEditingController();
  TextEditingController uidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordAgainController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController companyIdController = TextEditingController();
  TextEditingController accountantIdController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUID();
  }

  //CHECK LAST LOGIN
  Future<void> checkUID() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedUid = prefs.getString('uid') ?? '';
    idController.text = savedUid;
    setState(() {

    });
  }

  //CONVERT TURKISH CHARS TO ENGLISH CHARS
  String _toEnglishChar(String input) {
    return input
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G');
  }

  //GENERATE RANDOMIZED UID
  String generateUID(String value) {
    String eng = _toEnglishChar(value);
    List<String> words = eng.split(" ");
    String prefix = "";
    for (var w in words) {
      if (w.length >= 2) {
        prefix += w.substring(0, 2);
      } else {
        prefix += w;
      }
    }

    final random = Random();
    int number = random.nextInt(999999999);
    String numberStr = number.toString().padLeft(9, '0');

    return prefix + numberStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLogin ? 'Giriş Yap' : "Kayıt Ol",
          style:const  TextStyle(
            color: Color(0xFFEFEFEF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLogin ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row( //IS LOGIN PANEL ACTIVATED
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: ()  {
                        userType = "Admin"; //CHANGE USER TYPE
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userType == "Admin" ? const Color(0xFF0D1B2A) : const Color(0xFFAAB6C8),
                      ),
                      child: const Text(
                        'Muhasebeci',
                        style: TextStyle(
                          color: Color(0xFFEFEFEF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    ElevatedButton(
                      onPressed: ()  {
                          userType = "Company"; //CHANGE USER TYPE
                          setState(() {

                          });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userType == "Company" ? const Color(0xFF0D1B2A) : const Color(0xFFAAB6C8),
                      ),
                      child: const Text(
                        'Müvekkil',
                        style: TextStyle(
                          color: Color(0xFFEFEFEF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                const Text(
                  'Hoş Geldiniz!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEFEFEF),
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
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
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
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
                ),
                const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  //LOGIN IF USER EXIST FOR SELECTED USER TYPE

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
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giriş yapılırken bir sorun oluştu! Bilgilerinizi ve kullanıcı türünü kontrol edin.")));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1B2A),
                ),
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(
                    color: Color(0xFFEFEFEF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
                TextButton(
                    onPressed: (){
                      isLogin = false; //CHANGE PAGE TO SIGNUP PAGE
                      setState(() {

                      });
                    },
                    child: const Text("Hesabınız Yok Mu? Kayıt Olun!", style: TextStyle(color: Color(0xFFEFEFEF)),)
                )
              ],
            ) :
            userType == "Admin" ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: ()  {
                        userType = "Admin"; //CHANGE USER TYPE
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userType == "Admin" ? const Color(0xFF0D1B2A) : const Color(0xFFAAB6C8),
                      ),
                      child: const Text(
                        'Muhasebeci',
                        style: TextStyle(
                          color: Color(0xFFEFEFEF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    ElevatedButton(
                      onPressed: ()  {
                        userType = "Company"; //CHANGE USER TYPE
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userType == "Company" ? const Color(0xFF0D1B2A) : const Color(0xFFAAB6C8),
                      ),
                      child: const Text(
                        'Müvekkil',
                        style: TextStyle(
                          color: Color(0xFFEFEFEF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                const Text(
                  'Hoş Geldiniz!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEFEFEF),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'Sicil Numarası',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Muhasebe Kişi / Şirket İsmi',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
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
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  controller: passwordAgainController,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {  //CREATE ACCOUNT FOR NEW ACCOUNTANT
                    if (passwordController.text != passwordAgainController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Şifreler uyuşmuyor!"))
                      );
                      return;
                    }

                    if (idController.text.isEmpty || nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tüm alanları doldurun!"))
                      );
                      return;
                    }

                    await DatabaseHelper().createAdmin(
                      idController.text,
                      nameController.text,
                      "",
                      DateTime.now().add(const Duration(days: 365)).toString(),
                      passwordController.text,
                      "",
                      ""
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          AdminCompaniesPage(adminID: idController.text)
                      ),
                    );
                  },
                  child: const Text("Kayıt Ol"),
                ),
                TextButton(
                    onPressed: (){
                      isLogin = true; //CHANGE PAGE TO LOGIN PAGE
                      setState(() {

                      });
                },
                child: const Text("Hesabınız Var Mı? Giriş Yapın!", style: TextStyle(color: Color(0xFFEFEFEF)))
                )
              ],
            ) : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: ()  {
                        userType = "Admin"; //CHANGE USER TYPE
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userType == "Admin" ? const Color(0xFF0D1B2A) : const Color(0xFFAAB6C8),
                      ),
                      child: const Text(
                        'Muhasebeci',
                        style: TextStyle(
                          color: Color(0xFFEFEFEF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    ElevatedButton(
                      onPressed: ()  {
                        userType = "Company"; //CHANGE USER TYPE
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userType == "Company" ? const Color(0xFF0D1B2A) : const Color(0xFF908EC0),
                      ),
                      child: const Text(
                        'Müvekkil',
                        style: TextStyle(
                          color: Color(0xFFEFEFEF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                const Text(
                  'Hoş Geldiniz!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEFEFEF),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Kişi / Şirket İsmi',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: companyIdController,
                        decoration: InputDecoration(
                          labelText: 'Şirket Kullanıcı Adı',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: const TextStyle(color: Color(0xFFEFEFEF)),
                      ),
                    ),
                    IconButton(
                        onPressed: (){
                          String u = generateUID(nameController.text);
                          companyIdController.text = u;
                        },
                        icon: const Icon(Icons.rocket_launch_rounded))
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'Muhasebeci Sicil No',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: uidController,
                  decoration: InputDecoration(
                    labelText: 'Muhasebeci Benzersiz Kimlik',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
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
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  controller: passwordAgainController,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFEFEFEF)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {// CREATE ACCOUNT FOR NEW CLİENT
                    if (passwordAgainController.text != passwordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Şifreler uyuşmuyor!"))
                      );
                      return;
                    }

                    var acc = await DatabaseHelper().getAdminDetails(idController.text);
                    if (acc == null || acc.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Muhasebeci bulunamadı!"))
                      );
                      return;
                    }

                    if (acc["UID"] != uidController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Muhasebeci kimliği uyuşmuyor!"))
                      );
                      return;
                    }

                    // Şartlar sağlandı, şirket hesabı oluştur
                    await DatabaseHelper().createCompany(
                      companyIdController.text,
                      nameController.text,
                      idController.text,
                      "",
                      passwordController.text,
                      ""
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainMenu(
                          currentUserId: companyIdController.text,
                          isAdmin: false,
                          companyID: companyIdController.text,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B2A),
                  ),
                  child: const Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      color: Color(0xFFEFEFEF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                    onPressed: (){
                      isLogin = true; //CHANGE PAGE TO LOGIN PAGE
                      setState(() {

                      });
                    },
                    child: const Text("Hesabınız Var Mı? Giriş Yapın!", style: TextStyle(color: Color(0xFFEFEFEF)))
                )
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFAAB6C8),
    );
  }
}
