import 'package:flutter/material.dart';
import 'package:flutter_circle_flags_svg/flutter_circle_flags_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language extends StatefulWidget {
  const Language({Key? key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  @override
  void initState() {
    super.initState();
  }

  void _selectLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);

 Fluttertoast.showToast(
          msg: "Language is changed, click on the food can to start scanning",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.black,
        );
    
  }

  @override
  Widget build(BuildContext context) {
  //  final double screenWidth = MediaQuery.of(context).size.width;
    // final double iconSize = screenWidth * 0.15;
    // final double fontSize = screenWidth * 0.05;
     final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width; 
  final textScaleFactor = screenWidth > 600
        ? 1.4
        : screenWidth < 500
            ? 0.8
            : 1.2; 
    final iconSize = screenSize.width * 0.1 * textScaleFactor;


    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose your language:',
              style: TextStyle(fontSize: 24 * textScaleFactor),
            ),
            const SizedBox(height: 30),
            IconButton(
              icon: CircleFlag('gb', size: iconSize),
              iconSize: iconSize,
              onPressed: () => _selectLanguage('English'),
            ),
            const SizedBox(height: 30),
            IconButton(
              icon: CircleFlag('se', size: iconSize),
              iconSize: iconSize,
              onPressed: () => _selectLanguage('Swedish'),
            ),
            const SizedBox(height: 30),
            IconButton(
              icon: CircleFlag('es', size: iconSize),
              iconSize: iconSize,
              onPressed: () => _selectLanguage('Spanish'),
            ),
          ],
        ),
      ),
    );
  }
}
