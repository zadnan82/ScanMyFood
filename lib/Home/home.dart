// lib/Home/home.dart - Updated with proper back button handling for iOS/Android
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanmyfood/food.dart';
import 'package:scanmyfood/List/createlist.dart';
import 'package:scanmyfood/List/mylist.dart';
import 'package:scanmyfood/Home/language.dart';
import 'package:scanmyfood/Joining/signout.dart';
import 'package:scanmyfood/services/language_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final LanguageService _languageService = LanguageService.instance;

  // Pages for bottom navigation
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePages();
  }

  void _initializeAnimations() {
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

  void _initializePages() {
    _pages = [
      const FoodPage(), // Main scanning page
      const CreateList(), // Create custom list
      const MyList(), // Personal list scanning
      const Language(), // Language selection
      const SignOut(), // Account/Sign out
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  // Handle back button behavior
  Future<bool> _onWillPop() async {
    // If not on the main scanner tab, go back to it
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      _animationController.reset();
      _animationController.forward();
      return false; // Don't exit app
    }

    // If on main tab, show exit confirmation
    return await _showExitConfirmation();
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.exit_to_app,
                    color: const Color(0xFF6366F1),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _languageService.translate('app.exitApp', 'Exit App'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              content: Text(
                _languageService.translate('app.exitConfirmation',
                    'Are you sure you want to exit the app?'),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    _languageService.translate('common.cancel', 'Cancel'),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    // Force close the app
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _languageService.translate('common.exit', 'Exit'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF6366F1),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 14 : 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 12 : 10,
              ),
              iconSize: isTablet ? 28 : 24,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _currentIndex == 0
                          ? const Color(0xFF6366F1).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _currentIndex == 0
                          ? Icons.scanner
                          : Icons.scanner_outlined,
                      color: _currentIndex == 0
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  label: _languageService.translate('navigation.scan', 'Scan'),
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _currentIndex == 1
                          ? const Color(0xFF6366F1).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _currentIndex == 1
                          ? Icons.add_circle
                          : Icons.add_circle_outline,
                      color: _currentIndex == 1
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  label: _languageService.translate(
                      'navigation.createList', 'Create List'),
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _currentIndex == 2
                          ? const Color(0xFF6366F1).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _currentIndex == 2
                          ? Icons.list_alt
                          : Icons.list_alt_outlined,
                      color: _currentIndex == 2
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  label: _languageService.translate(
                      'navigation.myList', 'My List'),
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _currentIndex == 3
                          ? const Color(0xFF6366F1).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _currentIndex == 3
                          ? Icons.language
                          : Icons.language_outlined,
                      color: _currentIndex == 3
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  label: _languageService.translate(
                      'navigation.language', 'Language'),
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _currentIndex == 4
                          ? const Color(0xFF6366F1).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _currentIndex == 4
                          ? Icons.account_circle
                          : Icons.account_circle_outlined,
                      color: _currentIndex == 4
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  label: _languageService.translate(
                      'navigation.account', 'Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
