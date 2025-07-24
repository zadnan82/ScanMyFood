// lib/main.dart - Fixed version with proper state management
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // Initialize SharedPrefs
  await SharedPrefs().init();

  // Initialize Language Service
  await LanguageService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageService>.value(
      value: LanguageService.instance,
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: languageService.translate(
                'app.title', 'Food Ingredient Scanner'),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              // Clean, simplified color scheme
              colorScheme: ColorScheme.fromSeed(
                seedColor:
                    const Color(0xFF2563EB), // Clean blue instead of purple
                brightness: Brightness.light,
              ),
              // Clean typography
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                    color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                bodyMedium: TextStyle(color: Color(0xFF475569)),
              ),
              // Clean background
              scaffoldBackgroundColor: const Color(0xFFFAFAFA),
              // Simplified primary colors
              primaryColor: const Color(0xFF2563EB),
              // Clean app bar theme
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFF0F172A)),
                titleTextStyle: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Simplified card theme
              cardTheme: CardThemeData(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
              ),
              // Clean button themes
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              // Clean input decoration theme
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFEF4444), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              // Clean bottom navigation bar theme
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xFF2563EB),
                unselectedItemColor: Color(0xFF94A3B8),
                type: BottomNavigationBarType.fixed,
                elevation: 1,
              ),
            ),
            // Use AuthWrapper to handle authentication state
            home: const AuthWrapper(),
          );
        },
      ),
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
            backgroundColor: Color(0xFFFAFAFA),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Simplified loading with logo placeholder
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF2563EB),
                    child: Icon(
                      Icons.emoji_food_beverage,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                    ),
                  ),
                ],
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

// Loading widget for language changes
class LanguageLoadingOverlay extends StatelessWidget {
  final Widget child;

  const LanguageLoadingOverlay({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        if (languageService.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF2563EB),
                    child: Icon(
                      Icons.language,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    languageService.translate('common.loading', 'Loading...'),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
