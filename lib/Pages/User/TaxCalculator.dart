import 'package:direct_accounting/Pages/User/main_menu.dart';
import 'package:flutter/material.dart';


class TaxCalculationPage extends StatefulWidget {
  final String companyId;

  const TaxCalculationPage({Key? key, required this.companyId}) : super(key: key);

  @override
  State<TaxCalculationPage> createState() => _TaxCalculationPageState();
}

class _TaxCalculationPageState extends State<TaxCalculationPage> {
  final TextEditingController _priceController = TextEditingController();
  String? _selectedTax;
  final Map<String, double> _taxRatios = {
    'KDV (%20)': 0.2,
    'KDV (%18)': 0.18,
    'KDV (%8)': 0.08,
    'KDV (%1)': 0.01,
  };

  void _calcTax() {
    if (_selectedTax != null && _priceController.text.isNotEmpty) {
      final double price = double.tryParse(_priceController.text) ?? 0;
      final double taxRatio = _taxRatios[_selectedTax] ?? 0;
      final double taxAmount = price * taxRatio / (1 + taxRatio);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0D1B2A),
            title: const Text(
              'Vergi Hesaplama Sonucu',
              style: TextStyle(color: Color(0xFFEFEFEF)),
            ),
            content: Text(
              'Seçilen KDV: $_selectedTax\nHesaplanan KDV: ₺${taxAmount.toStringAsFixed(2)}\n'
                  'Gelir Vergisi : ₺${(price * 0.25).toStringAsFixed(2)}\nKalan : ₺${(price * 0.75 - taxAmount).toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFFEFEFEF)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Tamam',
                  style: TextStyle(color: Color(0xFFEFEFEF)),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun ve vergi türünü seçin.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainMenu(
                  currentUserId: widget.companyId,
                  isAdmin: false,
                  companyID: widget.companyId,
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFEFEFEF),
        ),
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Vergi Hesaplayıcı', style: TextStyle(color: Color(0xFFEFEFEF)),),
      ),
      backgroundColor: const Color(0xFFAAB6C8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Vergi Türünü Seçin',
              style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 18),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedTax,
              dropdownColor: const Color(0xFF0D1B2A),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0D1B2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Color(0xFFEFEFEF)),
              items: _taxRatios.keys.map((String vergi) {
                return DropdownMenuItem<String>(
                  value: vergi,
                  child: Text(vergi, style: const TextStyle(color: Color(0xFFEFEFEF))),
                );
              }).toList(),
              onChanged: (String? yeniDeger) {
                setState(() {
                  _selectedTax = yeniDeger;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Vergiler Dahil Fiyatı Girin',
              style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFFEFEFEF)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0D1B2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Örn: 1000',
                hintStyle: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calcTax,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Vergi Hesapla',
                style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}