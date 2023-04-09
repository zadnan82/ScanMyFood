import 'package:flutter/material.dart';
import 'package:scanmyfood/food.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'createlist.dart';
import 'language.dart';
import 'mylist.dart';
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
  final switchScreens = [const Language(), const FoodPage(), const CreateList(), const MyList()];

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

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //   getLanguage();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: flag == 'gb'
                ? CircleFlag(
                    flag,
                    size: 50,
                  )
                : CircleFlag(
                    flag,
                    size: 50,
                  ),
            label: "Language",
          ),
          const BottomNavigationBarItem(
            icon: Image(
              image: AssetImage("assets/images/foodcan.png"),
              width: 50,
              height: 50,
            ),
            label: "Food",
          ),
          const BottomNavigationBarItem(
            icon: Image(
              image: AssetImage("assets/images/edit.png"),
              width: 50,
              height: 50,
            ),
            label: "Create List",
          ),
          const BottomNavigationBarItem(
            icon: Image(
              image: AssetImage("assets/images/profile.png"),
              width: 50,
              height: 50,
            ),
            label: "My List",
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

      default:
        return Container();
    }
  }
}
