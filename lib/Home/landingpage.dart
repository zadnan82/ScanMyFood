// lib/Home/landingpage.dart - Updated version with Language Selector
import 'package:flutter/material.dart';
import 'package:flutter_circle_flags_svg/flutter_circle_flags_svg.dart';
import 'package:scanmyfood/Home/LandingScannerPage.dart';
import 'package:scanmyfood/Home/language.dart';
import 'package:scanmyfood/Joining/signin.dart';
import 'package:scanmyfood/Joining/signup.dart';
import 'package:scanmyfood/services/language_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final LanguageService _languageService = LanguageService.instance;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLanguageService();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeLanguageService() async {
    await _languageService.initialize();
    if (mounted) {
      setState(() {}); // Refresh UI with loaded translations
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: const Color(0xFF6366F1),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _languageService.translate(
                              'language.title', 'Choose Language'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _languageService.translate('language.subtitle',
                              'Select your preferred language'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Language List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: LanguageService.supportedLanguages.length,
                itemBuilder: (context, index) {
                  final languageEntry = LanguageService
                      .supportedLanguages.entries
                      .elementAt(index);
                  final languageName = languageEntry.key;
                  final languageData = languageEntry.value;
                  final isSelected =
                      _languageService.currentLanguage == languageName;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6366F1).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: CircleFlag(
                        languageData['flag']!,
                        size: 32,
                      ),
                      title: Text(
                        languageName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF6366F1),
                              size: 24,
                            )
                          : null,
                      onTap: () async {
                        if (languageName != _languageService.currentLanguage) {
                          await _languageService.changeLanguage(languageName);

                          Fluttertoast.showToast(
                            msg:
                                "${_languageService.translate('language.languageChanged', 'Language changed to')} $languageName",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: const Color(0xFF10B981),
                            textColor: Colors.white,
                          );

                          setState(() {}); // Refresh the entire page
                        }
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),

            // Close Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _languageService.translate('common.close', 'Close'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header with Language Selector
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            // Top row with language selector and sign in
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Language Selector Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: _showLanguageSelector,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleFlag(
                                              _languageService.currentFlag,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _languageService.currentLanguage,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Sign In Button
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SignIn()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _languageService.translate(
                                        'auth.signIn', 'Sign In'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // App Logo
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: isTablet ? 120 : 100,
                                height: isTablet ? 120 : 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/app_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // App Title
                            Text(
                              _languageService.translate(
                                  'app.title', 'Food Ingredient Scanner'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 36 : 30,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 12),

                            // App Subtitle
                            Text(
                              _languageService.translate('app.subtitle',
                                  'Check your food for harmful ingredients'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isTablet ? 20 : 18,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Main Content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 32 : 24),
                          child: Column(
                            children: [
                              // Features Grid
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFeatureCard(
                                      icon: Icons.scanner,
                                      title: _languageService.translate(
                                          'landing.instantScanning',
                                          'Instant Scanning'),
                                      subtitle: _languageService.translate(
                                          'landing.scanDescription',
                                          'Take a photo and get results instantly'),
                                      color: const Color(0xFF6366F1),
                                      isTablet: isTablet,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      icon: Icons.health_and_safety,
                                      title: _languageService.translate(
                                          'landing.healthProtection',
                                          'Health Protection'),
                                      subtitle: _languageService.translate(
                                          'landing.protectDescription',
                                          'Detect harmful ingredients before you consume'),
                                      color: const Color(0xFF10B981),
                                      isTablet: isTablet,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFeatureCard(
                                      icon: Icons.language,
                                      title: _languageService.translate(
                                          'landing.multiLanguage',
                                          'Multi-Language'),
                                      subtitle: _languageService.translate(
                                          'landing.languageDescription',
                                          'Available in multiple languages'),
                                      color: const Color(0xFFF59E0B),
                                      isTablet: isTablet,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      icon: Icons.list_alt,
                                      title: _languageService.translate(
                                          'landing.customLists',
                                          'Custom Lists'),
                                      subtitle: _languageService.translate(
                                          'landing.listsDescription',
                                          'Create personal ingredient blacklists'),
                                      color: const Color(0xFF8B5CF6),
                                      isTablet: isTablet,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // Call to Action Buttons
                              Column(
                                children: [
                                  // Try Scanner Button
                                  Container(
                                    width: double.infinity,
                                    height: isTablet ? 60 : 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1)
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LandingScannerPage()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: isTablet ? 24 : 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _languageService.translate(
                                                'landing.tryScanner',
                                                'Try Our Scanner'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isTablet ? 18 : 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Create Account Button
                                  Container(
                                    width: double.infinity,
                                    height: isTablet ? 56 : 52,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUp()),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFF6366F1), width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_add,
                                            color: const Color(0xFF6366F1),
                                            size: isTablet ? 20 : 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _languageService.translate(
                                                'landing.createFreeAccount',
                                                'Create Free Account'),
                                            style: TextStyle(
                                              color: const Color(0xFF6366F1),
                                              fontSize: isTablet ? 16 : 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Quick Language Access
                                  Text(
                                    _languageService.translate(
                                        'landing.availableIn',
                                        'Available in multiple languages'),
                                    style: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: isTablet ? 14 : 12,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Language Flags Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: LanguageService
                                        .supportedLanguages.values
                                        .take(3)
                                        .map((langData) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: CircleFlag(
                                                langData['flag']!,
                                                size: isTablet ? 28 : 24,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: isTablet ? 24 : 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: const Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
