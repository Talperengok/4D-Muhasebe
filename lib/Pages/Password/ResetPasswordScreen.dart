import '../User/LoginPage.dart';
import 'package:flutter/material.dart';
import '../../Services/Database/DatabaseHelper.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String userId;
  final String type;

  ResetPasswordScreen({required this.userId, required this.type});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final DatabaseHelper db = DatabaseHelper();
  bool _loading = false;

  void _resetPassword() async {
    setState(() => _loading = true);

    String result;
    if (widget.type == "Admin") {
      result = await db.updateAdminPassword(widget.userId, _passwordController.text.trim());
    } else {
      result = await db.updateCompanyPassword(widget.userId, _passwordController.text.trim());
    }

    setState(() => _loading = false);

    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Şifre başarıyla değiştirildi")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Şifre değiştirilemedi")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yeni Şifre Belirle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Yeni Şifre"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _resetPassword,
                    child: Text("Şifreyi Sıfırla"),
                  ),
          ],
        ),
      ),
    );
  }
}