 import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; 
import 'package:scanmyfood/landingpage.dart';
import 'package:scanmyfood/shared_prefs.dart'; 
import 'dbHelper/mongodb.dart';
import 'firebase_options.dart';
 
Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await MongoDatabase.connect();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPrefs().init(); 
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return MaterialApp(
        //     title: 'CheckMe',
        //     debugShowCheckedModeBanner: false,
        //     theme: ThemeData(
        //       primarySwatch: Colors.green,
        //       primaryColor: Color.fromARGB(255, 0, 0, 0),
        //     ),
        //     home: SignIn(),
        //   );
        // } else if (snapshot.hasError) {
        //   return const MaterialApp(
        //     home: Scaffold(
        //       body: Center(
        //         child: Text(
        //           "An error ",
        //           style: TextStyle(
        //               color: Colors.cyan,
        //               fontSize: 40,
        //               fontWeight: FontWeight.bold),
        //         ),
        //       ),
        //     ),
        //   );
        // }

        return MaterialApp(
          title: 'CheckMe',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.orange,
            primaryColor: const Color.fromARGB(255, 4, 4, 4),
          ),
          home: LandingPage(),
        );
    //   },
    // );
  }
}

 
 