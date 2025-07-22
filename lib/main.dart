import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scanmyfood/Home/landingpage.dart';
import 'package:scanmyfood/dbHelper/shared_prefs.dart';
import 'dbHelper/mongodb.dart';
import 'dbHelper/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // REMOVE the MongoDB.connect() line completely
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPrefs().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.orange),
          bodyMedium: TextStyle(color: Colors.orange),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 0, 0, 0),
        primarySwatch: Colors.orange,
        primaryColor: Color.fromARGB(255, 249, 247, 247),
      ),
      home: LandingPage(),
    );
  }
}
