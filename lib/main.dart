import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'login_page.dart'; // Import LoginPage
import 'home_page.dart'; // Import HomePage
import 'profile_page.dart'; // Import profile_page.dart
import 'register_page.dart'; // Import RegisterPage
import 'reset_page.dart'; // Import ResetPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding selesai
  try {
    await Firebase.initializeApp(); // Inisialisasi Firebase
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Freshly',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity:
            VisualDensity.adaptivePlatformDensity, // Optimasi tampilan
      ),
      initialRoute: '/login', // Rute awal
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
        '/register': (context) => const RegisterPage(),
        '/reset': (context) => const ResetPage(), // Tambahkan rute di sini
      },
      onUnknownRoute: (settings) {
        // Menangani rute yang tidak dikenal dengan fallback ke halaman login
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
    );
  }
}
