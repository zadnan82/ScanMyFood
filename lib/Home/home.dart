// lib/Home/home.dart - Simplified clean navigation
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      duration: const Duration(milliseconds: 200),
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
    final languageService = context.read<LanguageService>();

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
                  const Icon(
                    Icons.exit_to_app,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    languageService.translate('app.exitApp', 'Exit App'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              content: Text(
                languageService.translate('app.exitConfirmation',
                    'Are you sure you want to exit the app?'),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    languageService.translate('common.cancel', 'Cancel'),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    languageService.translate('common.exit', 'Exit'),
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
        backgroundColor: Colors.white,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF2563EB),
                  unselectedItemColor: const Color(0xFF94A3B8),
                  selectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 12 : 11,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 11 : 10,
                  ),
                  iconSize: isTablet ? 24 : 22,
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _currentIndex == 0
                              ? const Color(0xFF2563EB).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _currentIndex == 0
                              ? Icons.scanner
                              : Icons.scanner_outlined,
                        ),
                      ),
                      label:
                          languageService.translate('navigation.scan', 'Scan'),
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _currentIndex == 1
                              ? const Color(0xFF2563EB).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _currentIndex == 1
                              ? Icons.add_circle
                              : Icons.add_circle_outline,
                        ),
                      ),
                      label: languageService.translate(
                          'navigation.createList', 'Create'),
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _currentIndex == 2
                              ? const Color(0xFF2563EB).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _currentIndex == 2
                              ? Icons.list_alt
                              : Icons.list_alt_outlined,
                        ),
                      ),
                      label: languageService.translate(
                          'navigation.myList', 'My List'),
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _currentIndex == 3
                              ? const Color(0xFF2563EB).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _currentIndex == 3
                              ? Icons.language
                              : Icons.language_outlined,
                        ),
                      ),
                      label: languageService.translate(
                          'navigation.language', 'Language'),
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _currentIndex == 4
                              ? const Color(0xFF2563EB).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _currentIndex == 4
                              ? Icons.account_circle
                              : Icons.account_circle_outlined,
                        ),
                      ),
                      label: languageService.translate(
                          'navigation.account', 'Account'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
