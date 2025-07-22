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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    getLanguage();
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? language = "";
  String flag = "";
  int index = 0;
  final switchScreens = [
    const Language(),
    const FoodPage(),
    const CreateList(),
    const MyList(),
    SignOut()
  ];

  Future getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    language = prefs.getString('language');

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
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light gray-blue background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _getPage(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF6366F1), // Indigo
            unselectedItemColor: const Color(0xFF94A3B8), // Slate gray
            selectedFontSize: isTablet ? 14 : 12,
            unselectedFontSize: isTablet ? 12 : 10,
            iconSize: isTablet ? 28 : 24,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              getLanguage();

              // Add haptic feedback
              // HapticFeedback.selectionClick();
            },
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircleFlag(
                    flag,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                label: "Language",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.scanner,
                    size: isTablet ? 24 : 20,
                    color: _selectedIndex == 1
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                label: "Scan",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: isTablet ? 24 : 20,
                    color: _selectedIndex == 2
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                label: "Create List",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 3
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    size: isTablet ? 24 : 20,
                    color: _selectedIndex == 3
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                label: "My List",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 4
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.logout,
                    size: isTablet ? 24 : 20,
                    color: _selectedIndex == 4
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                label: "Sign Out",
              ),
            ],
          ),
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
