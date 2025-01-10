import 'package:direct_accounting/Pages/User/LoginPage.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Direkt Muhasebe',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
        //abkteknoltd
      home: LoginPage() //AdminPanelPage(), ///Gerektiğinde Admin Paneli açılacak
    );
  }
}


//HaSi352299031 - 12345
//ABLT573074829
//HALT135112727
//LiNe865360282
//ACOtKi707309744
