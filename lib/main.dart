import 'package:direct_accounting/Pages/User/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔙 Arka planda mesaj alındı: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Lokal bildirim ayarları
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;

  @override
  void initState() {
    super.initState();
    requestPermission();
    listenFCMMessages();
    getToken();
  }

  void requestPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true, badge: true, sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('📲 Kullanıcı bildirim izni verdi');
    } else {
      print('🚫 Kullanıcı bildirim izni vermedi');
    }
  }

  void getToken() async {
    _token = await FirebaseMessaging.instance.getToken();
    print('🪪 FCM Token: $_token');
    // Burada token'ı backend'e gönderebilirsin
  }

  void listenFCMMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Genel Bildirim Kanalı',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4D Muhasebe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D1B2A)),
        useMaterial3: true,
      ),
      //abkteknoltd
      home: const LoginPage(),//AdminPanelPage(), ///Gerektiğinde Admin Paneli açılacak
    );
  }
}
//HaSi352299031 - 12345
//ABLT573074829
//HALT135112727
//LiNe865360282
//ACOtKi707309744
