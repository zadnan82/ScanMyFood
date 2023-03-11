 
import 'package:flutter/material.dart';
import 'package:scanmyfood/home_page.dart';


void main() {
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: 'CheckMe',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.green,
              primaryColor: Colors.white,
            ),
            home: const HomePage(),
          );
        } else if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  "An error ",
                  style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'CheckMe',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.grey,
            primaryColor: Colors.white,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}