import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import file-file Anda
import 'package:project_iwaq/screen/home_screen.dart';
import 'package:project_iwaq/screen/login_screen.dart';
import 'package:project_iwaq/services/auth_services.dart';
import 'package:project_iwaq/services/data_services.dart'; // Pastikan file ini ada
import 'package:project_iwaq/widget/session_guard.dart'; // Import file baru tadi

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Pastikan Anda sudah setup firebase_options.dart jika menggunakan FlutterFire CLI
    // Atau file google-services.json di folder android/app
    await Firebase.initializeApp();
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Pastikan DataService sudah dibuat filenya, kalau belum comment dulu baris ini
        ChangeNotifierProvider(create: (_) => DataService()), 
        StreamProvider<User?>.value(
          value: AuthService().user,
          initialData: null,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iWAQ Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', 
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Widget Penentu Alur (Wrapper)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const LoginScreen();
    } else {
      // --- DISINI PERUBAHANNYA ---
      // Kita bungkus HomeScreen dengan SessionGuard
      // Agar dicek terus menerus ke database
      return SessionGuard(
        child: const HomeScreen(),
      );
    }
  }
}