// lib/main.dart - Updated version with proper auth flow
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scanmyfood/Home/landingpage.dart';
import 'package:scanmyfood/Home/home.dart';
import 'package:scanmyfood/dbHelper/shared_prefs.dart';
import 'package:scanmyfood/services/language_service.dart';
import 'dbHelper/mongodb.dart';
import 'dbHelper/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPrefs (for backward compatibility)
  await SharedPrefs().init();

  // Initialize Language Service
  await LanguageService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ingredient Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Modern color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        // Typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF0F172A)),
          bodyMedium: TextStyle(color: Color(0xFF475569)),
        ),
        // Background
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        // Primary colors
        primaryColor: const Color(0xFF6366F1),
        // App bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Card theme
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        // Bottom navigation bar theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6366F1),
          unselectedItemColor: Color(0xFF94A3B8),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      // Use AuthWrapper to handle authentication state
      home: const AuthWrapper(),
    );
  }
}

// AuthWrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          );
        }

        // If user is signed in, show main app
        if (snapshot.hasData && snapshot.data != null) {
          return const Home();
        }

        // If user is not signed in, show landing page
        return const LandingPage();
      },
    );
  }
}
