import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';

// 🔔 GLOBAL NOTIFICATION PLUGIN
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> requestNotificationPermission() async {
  // 🔹 Android 13 (API 33+) wajib POST_NOTIFICATIONS
  final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    await androidPlugin.requestNotificationsPermission();
  }
}

// 🔔 Izinkan Exact Alarm (Android 12+)
Future<void> requestExactAlarmPermission() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  if (androidInfo.version.sdkInt >= 31) {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // ✨ PERBAIKAN: gunakan API baru 'areNotificationsEnabled'
    final bool granted = await androidPlugin?.areNotificationsEnabled() ?? false;

    if (!granted) {
      print("⚠️ Exact alarm permission belum diberikan (Android 12+).");
      // Jika mau, bisa arahkan user ke pengaturan manual, karena requestExactAlarmsPermission() sudah deprecated
      // await androidPlugin?.requestExactAlarmsPermission(); // Opsional: tergantung versi
    } else {
      print("✅ Exact alarm permission granted");
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 1. Init Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Initialized");
  } catch (e) {
    print("❌ Firebase Error: $e");
  }

  // 🔹 2. Init Local Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 🔹 3. Request Permissions
  await requestNotificationPermission();      // Android 13+
  await requestExactAlarmPermission();        // Android 12+ (diperbarui)

  // 🔹 4. Test Firestore
  try {
    await FirebaseFirestore.instance
        .collection('test')
        .add({'status': 'connected', 'time': DateTime.now()});
    print('✅ Firestore Ready');
  } catch (e) {
    print('⚠️ Firestore Error: $e');
  }

  // 🔹 5. Run App
  runApp(const SistemPeternakanApp());
}

class SistemPeternakanApp extends StatelessWidget {
  const SistemPeternakanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistem Informasi Peternakan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
