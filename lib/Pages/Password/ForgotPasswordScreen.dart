import 'package:flutter/material.dart';
import 'PinVerificationScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _idController = TextEditingController();
  String _selectedType = "Admin";

  void _continue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinVerificationScreen(
          userId: _idController.text.trim(),
          type: _selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Şifremi Unuttum")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedType,
              onChanged: (val) {
                setState(() => _selectedType = val!);
              },
              items: ["Admin", "Company"].map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
            ),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: "Kullanıcı ID"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _continue,
              child: Text("Devam"),
            )
          ],
        ),
      ),
    );
  }
}