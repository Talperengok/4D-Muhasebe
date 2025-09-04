import '../User/TaxCalculator.dart';
import 'CompanyConfirmPage.dart';
import 'package:flutter/material.dart';
import '../../Services/Database/DatabaseHelper.dart';
import '../../Components/CustomDrawer.dart';
import 'AdminCompaniesPage.dart';
import 'ArchivedCompaniesPage.dart';
import 'AdminUpdatePage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

class PremiumUpgradePage extends StatefulWidget {
  final String adminID;

  const PremiumUpgradePage({required this.adminID, Key? key}) : super(key: key);

  @override
  State<PremiumUpgradePage> createState() => _PremiumUpgradePageState();
}

class _PremiumUpgradePageState extends State<PremiumUpgradePage> {
  bool _isLoading = false;
  String? _error;
  Map<String, String>? _selectedPackage;
  String _selectedDuration = "30";
  String _premiumType = 'standard';

  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _storeAvailable = false;

  @override
  void initState() {
    super.initState();
    _initStore();
    _subscription = _iap.purchaseStream.listen(_onPurchaseUpdated, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      setState(() {
        _error = "Satın alma sırasında bir hata oluştu: $error";
      });
    });
  }

  void _initStore() async {
    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) {
      setState(() {
        _error = "Satın alma mağazası kullanılamıyor.";
      });
      return;
    }

    const Set<String> _kIds = {
      '30_gunluk_gelismis_paket',
      '30_gunluk_super_gelismis_paket',
      '365_gunluk_gelismis_paket',
      '365_gunluk_super_gelismis_paket',
    };

    final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
    if (response.error != null) {
      setState(() {
        _error = "Ürünler alınamadı: ${response.error!.message}";
      });
      return;
    }

    setState(() {
      _products = response.productDetails;
    });

    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ürün listesi boş, mağaza ürünlerini kontrol edin."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mağaza ürünleri yüklendi: ${_products.map((e) => e.id).join(', ')}"),
        ),
      );
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _finalizePurchase();
      }
    }
  }

  Widget buildPackageCard(Map<String, String> value, String title, String price, List<String> features) {
    bool selected = _selectedPackage?['value'] == value['value'];
    Color gradient1 = value['value']!.startsWith("30") ? Colors.orange.shade100 : Colors.blue.shade100;
    Color gradient2 = value['value']!.startsWith("30") ? Colors.orange.shade200 : Colors.blue.shade200;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = value;
          print("Seçilen paket: $_selectedPackage");
        });
      },
      child: Center(
        child: Container(
          width: 500,
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradient1, gradient2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF0D1B2A) : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: const Color(0xFF0D1B2A).withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  price,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Avantajlar:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 6),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("• $f", style: const TextStyle(fontSize: 15)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _upgrade() async {
    if (_selectedPackage == null || !_storeAvailable) {
      print("Paket seçilmedi veya mağaza kullanılamıyor.");
      return;
    }

    String productId = "";
    switch (_selectedPackage!['value']) {
      case "30_limited":
        productId = "30_gunluk_gelismis_paket";
        break;
      case "30_unlimited":
        productId = "30_gunluk_super_gelismis_paket";
        break;
      case "365_limited":
        productId = "365_gunluk_gelismis_paket";
        break;
      case "365_unlimited":
        productId = "365_gunluk_super_gelismis_paket";
        break;
      default:
        print("Bilinmeyen paket seçimi: ${_selectedPackage!['value']}");
        return;
    }

    print("Seçilen productId: $productId");

    if (_products.isEmpty) {
      print("Ürünler boş, mağazadan çekilemiyor.");
      return;
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () {
        print("Ürün bulunamadı: $productId");
        setState(() {
          _error = "Ürün bulunamadı.";
        });
        return ProductDetails(
          id: '',
          title: '',
          description: '',
          price: '',
          rawPrice: 0,
          currencyCode: '',
        );
      },
    );

    if (product.id == '') return;

    final purchaseParam = PurchaseParam(productDetails: product);
    print("Satın alma başlatılıyor: ${product.id}");
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _finalizePurchase() async {
    if (_selectedPackage == null) return;
    setState(() {
      _isLoading = true;
    });

    String type = _selectedPackage!['label']!.contains("sınırsız") ? 'unlimited' : 'limited';
    int days = _selectedPackage!['value']!.startsWith("30") ? 30 : 365;

    final response = await DatabaseHelper().upgradeAdminToPremiumWithDetails(
      widget.adminID,
      type,
      days,
    );

    if (response == 'success') {
      setState(() {
        _isLoading = false;
        _premiumType = type;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Premium üyeliğiniz aktif edildi.")),
      );
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isLoading = false;
        _error = "Yükseltme başarısız oldu.";
      });
    }
  }

  int getClientLimit() {
    if (_premiumType == 'unlimited') return 999999;
    if (_premiumType == 'limited') return 100;
    return 10;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFEFEFEF)),
        title: const Text(
          "Premium Üyelik Yükseltme",
          style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      drawer: AdminDrawer(
        onButton1Pressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminCompaniesPage(adminID: widget.adminID)),
          );
        },
        onButton2Pressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaxCalculationPage(companyId: widget.adminID, isAdmin: true),
            ),
          );
        },
        onButton3Pressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ArchivedCompaniesPage(adminID: widget.adminID),
            ),
          );
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
        onButton5Pressed: () {},
        onButton6Pressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyConfirmPage(adminID: widget.adminID),
            ),
          );
        },
        page: 5,
      ),
      backgroundColor: const Color(0xFFAAB6C8),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedDuration = "30";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedDuration == "30" ? Colors.orange : Colors.grey.shade300,
                            foregroundColor: _selectedDuration == "30" ? Colors.white : Colors.black,
                          ),
                          child: const Text("30 Günlük"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedDuration = "365";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedDuration == "365" ? Colors.blue : Colors.grey.shade300,
                            foregroundColor: _selectedDuration == "365" ? Colors.white : Colors.black,
                          ),
                          child: const Text("365 Günlük"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedDuration == "30") ...[
                      buildPackageCard(
                        {"value": "30_limited", "label": "30_sınırlı"},
                        "Gelişmiş Paket",
                        "₺59,90",
                        ["Müvekkil sınırı: 10 → 100", "Temel destek"],
                      ),
                      buildPackageCard(
                        {"value": "30_unlimited", "label": "30_sınırsız"},
                        "Süper Gelişmiş Paket",
                        "₺129,90",
                        ["Müvekkil sınırı: 10 → ∞", "Öncelikli destek"],
                      ),
                    ] else ...[
                      buildPackageCard(
                        {"value": "365_limited", "label": "365_sınırlı"},
                        "Gelişmiş Paket",
                        "₺399,90",
                        ["Müvekkil sınırı: 10 → 100", "Temel destek"],
                      ),
                      buildPackageCard(
                        {"value": "365_unlimited", "label": "365_sınırsız"},
                        "Süper Gelişmiş Paket",
                        "₺999,90",
                        ["Müvekkil sınırı: 10 → ∞", "Öncelikli destek"],
                      ),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _selectedPackage == null ? null : _upgrade,
                        icon: const Icon(Icons.star),
                        label: const Text("Premium'a Geç"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}