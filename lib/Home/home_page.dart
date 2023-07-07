import 'package:flutter/material.dart';
import 'package:scanmyfood/food.dart';
import 'package:scanmyfood/Joining/signout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../List/createlist.dart';
import 'language.dart';
import '../List/mylist.dart';
import 'package:flutter_circle_flags_svg/flutter_circle_flags_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    getLanguage();
    super.initState();
  }

  String? language = "";
  String flag = "";
  int index = 0;
  final switchScreens = [const Language(), const FoodPage(), const CreateList(), const MyList(), SignOut()];

  Future getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    language =  prefs.getString('language');

    if (language == null || language == 'English') {
      setState(() {
        flag = 'gb';
      });
    } else if (language == 'Swedish') {
      setState(() {
        flag = 'se';
      });
    } else if (language == 'Spanish') {
      setState(() {
        flag = 'es';
      });
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width; 
    final double iconSize = screenWidth * 0.1; 

    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: flag == 'gb'
                  ? CircleFlag(
                      flag,
                      size: iconSize,
                    )
                  : CircleFlag(
                      flag,
                      size: iconSize,
                    ),
              label: "Language",
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Image(
                image: AssetImage("assets/images/foodcan.png"),
                width: iconSize,
                height: iconSize,
              ),
              label: "Food",
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Image(
                image: AssetImage("assets/images/edit.png"),
                width: iconSize,
                height: iconSize,
              ),
              label: "Create List",
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Image(
                image: AssetImage("assets/images/profile.png"),
                width: iconSize,
                height: iconSize,
              ),
              label: "My List",
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Image(
                image: AssetImage("assets/images/signout.png"),
                width: iconSize,
                height: iconSize,
              ),
              label: "Sign Out",
              backgroundColor: Colors.black,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            getLanguage();
          },
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const Language();
      case 1:
        return const FoodPage();
      case 2:
        return const CreateList();
      case 3:
        return const MyList();
      case 4:
        return SignOut();
      default:
        return Container();
    }
  }
}
