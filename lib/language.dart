import 'package:flutter/material.dart';
import 'package:flutter_circle_flags_svg/flutter_circle_flags_svg.dart';
import 'package:scanmyfood/home_page.dart';
import 'package:scanmyfood/main.dart';
import 'package:scanmyfood/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const Language());
}

class Language extends StatelessWidget {
  const Language({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedLanguage = "";

  void _selectLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);

    setState(() {
      _selectedLanguage = language;
    });

  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Language is changed, klick on the hamburger to start scanning"),
      ));

  //  Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               Language()),
  //           (Route<dynamic> route) =>
  //       false);
              
  }

  // void navigateToNextPage() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => NextPage(),
  //     ),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  void _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language');
    if (language != null) {
      setState(() {
        _selectedLanguage = language;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose your language:',
            style: TextStyle(fontSize: 20),
          ),
           const Padding(padding: EdgeInsets.only(top: 30)),
                  
                   IconButton(
                icon: CircleFlag('gb', size: 60,),
                iconSize: 50,
                onPressed: () => _selectLanguage('English'),
              ),

          
        
    const Padding(padding: EdgeInsets.only(top: 30)),
                  
                   IconButton(
                icon: CircleFlag('se', size: 60,),
                iconSize: 50,
                onPressed: () => _selectLanguage('Swedish'),
              ),
                  
          const Padding(padding: EdgeInsets.only(top: 30)),
                  
                   IconButton(
                icon: CircleFlag('es', size: 60,),
                iconSize: 50,
                onPressed: () => _selectLanguage('Spanish'),
              ),
            const Padding(padding: EdgeInsets.only(top: 30)),
                  
          // SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: _selectedLanguage == null ? null : navigateToNextPage,
          //   child: Text('Next'),
          // ),
        ],
      ),
      )
    );
  }
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: _getLanguage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                'You selected ${snapshot.data}',
                style: TextStyle(fontSize: 24),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Future<String> _getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language')!;
  }
}