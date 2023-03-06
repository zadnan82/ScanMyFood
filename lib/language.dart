import 'package:flutter/material.dart';
import 'package:flutter_circle_flags_svg/flutter_circle_flags_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language extends StatefulWidget {


  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  @override
  void initState() {
    super.initState();
     _loadSelectedLanguage();
  }

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
