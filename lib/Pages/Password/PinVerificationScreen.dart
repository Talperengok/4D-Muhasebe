import 'package:flutter/material.dart';
import '../../Services/Database/DatabaseHelper.dart';
import 'ResetPasswordScreen.dart';

class PinVerificationScreen extends StatefulWidget {
  final String userId;
  final String type;

  PinVerificationScreen({required this.userId, required this.type});

  @override
  _PinVerificationScreenState createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final _pinController = TextEditingController();
  final DatabaseHelper db = DatabaseHelper();
  bool _loading = false;

  void _verifyPin() async {
    setState(() => _loading = true);
    bool result = await db.verifyUserPin(widget.type, widget.userId, _pinController.text.trim());
    setState(() => _loading = false);

    if (result) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            userId: widget.userId,
            type: widget.type,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PIN yanlış!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PIN Doğrulama")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: "PIN"),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyPin,
                    child: Text("Doğrula"),
                  ),
          ],
        ),
      ),
    );
  }
}