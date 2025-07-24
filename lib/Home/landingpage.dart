// lib/Home/landingpage.dart - Complete clean version with cosmetics promotion
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:scanmyfood/Home/LandingScannerPage.dart';
import 'package:scanmyfood/Joining/signin.dart';
import 'package:scanmyfood/Joining/signup.dart';
import 'package:scanmyfood/services/language_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Language data with emoji flags
  final Map<String, String> languageFlags = {
    'English': '🇬🇧',
    'Spanish': '🇪🇸',
    'Swedish': '🇸🇪',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Get the appropriate app store URL based on platform
  String _getCosmeticsAppUrl() {
    if (kIsWeb) {
      return 'https://play.google.com/store/apps/details?id=com.zainabadnan.scanmylotions&hl=en';
    }

    if (Platform.isIOS) {
      return 'https://apps.apple.com/se/app/cosmetics-checker/id6447474601';
    } else {
      return 'https://play.google.com/store/apps/details?id=com.zainabadnan.scanmylotions&hl=en';
    }
  }

  // Get the appropriate store name
  String _getStoreName() {
    if (kIsWeb) return 'Google Play';
    return Platform.isIOS ? 'App Store' : 'Google Play';
  }

  // Get the appropriate store icon
  IconData _getStoreIcon() {
    if (kIsWeb) return Icons.shop;
    return Platform.isIOS ? Icons.apple : Icons.shop;
  }

  Future<void> _launchCosmeticsApp() async {
    final url = _getCosmeticsAppUrl();
    final uri = Uri.parse(url);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: context
                .read<LanguageService>()
                .translate('errors.cantOpenStore', 'Could not open app store'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: context
              .read<LanguageService>()
              .translate('errors.cantOpenStore', 'Could not open app store'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          textColor: Colors.white,
        );
      }
    }
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
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.language,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return Text(
                              languageService.translate(
                                  'language.title', 'Choose Language'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return Text(
                              languageService.translate('language.subtitle',
                                  'Select your preferred language'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Language List
            Expanded(
              child: Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: LanguageService.supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final languageName = LanguageService
                          .supportedLanguages.keys
                          .elementAt(index);
                      final isSelected =
                          languageService.currentLanguage == languageName;
                      final flag = languageFlags[languageName] ?? '🌐';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB).withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: languageService.isLoading
                              ? null
                              : () async {
                                  try {
                                    await languageService
                                        .changeLanguage(languageName);
                                    if (mounted) {
                                      Navigator.pop(context);
                                      Fluttertoast.showToast(
                                        msg:
                                            "${languageService.translate('language.languageChanged', 'Language changed to')} $languageName",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor:
                                            const Color(0xFF10B981),
                                        textColor: Colors.white,
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      Fluttertoast.showToast(
                                        msg: languageService.translate(
                                            'common.error',
                                            'An error occurred'),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor:
                                            const Color(0xFFEF4444),
                                        textColor: Colors.white,
                                      );
                                    }
                                  }
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  flag,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    languageName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2563EB),
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header with Language Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          final currentFlag =
                              languageFlags[languageService.currentLanguage] ??
                                  '🌐';
                          return InkWell(
                            onTap: _showLanguageSelector,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      const Color(0xFF2563EB).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(currentFlag,
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    languageService.currentLanguage,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF2563EB),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 60 : 40),

                  // Logo
                  Container(
                    width: isTablet ? 120 : 100,
                    height: isTablet ? 120 : 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/app_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 40 : 32),

                  // Title
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.translate('app.title', 'ScanMyFood'),
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontSize: isTablet ? 36 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  SizedBox(height: isTablet ? 16 : 12),

                  // Subtitle
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.translate('app.subtitle',
                            'Protect your health by scanning ingredient labels'),
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: isTablet ? 18 : 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  SizedBox(height: isTablet ? 48 : 40),

                  // Main Action Buttons
                  Column(
                    children: [
                      // Try Scanner Button
                      SizedBox(
                        width: double.infinity,
                        height: isTablet ? 56 : 52,
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
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Consumer<LanguageService>(
                                builder: (context, languageService, child) {
                                  return Text(
                                    languageService.translate(
                                        'landing.tryScanner',
                                        'Try Scanner (No Sign-up Required)'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: isTablet ? 56 : 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person_add,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Consumer<LanguageService>(
                                builder: (context, languageService, child) {
                                  return Text(
                                    languageService.translate(
                                        'landing.signUpFree', 'Sign Up Free'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                languageService.translate(
                                    'auth.alreadyHaveAccount',
                                    'Already have an account? '),
                                style: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              );
                            },
                          ),
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SignIn()),
                                  );
                                },
                                child: Text(
                                  languageService.translate(
                                      'auth.signIn', 'Sign In'),
                                  style: TextStyle(
                                    color: const Color(0xFF2563EB),
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Sister App Promotion Section
                  Container(
                    padding: EdgeInsets.all(isTablet ? 24 : 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.1),
                          const Color(0xFF06B6D4).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/cosmeticsapplogo.png',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback if image doesn't load
                                    return const Icon(
                                      Icons.face_retouching_natural,
                                      color: Color(0xFF8B5CF6),
                                      size: 24,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<LanguageService>(
                                    builder: (context, languageService, child) {
                                      return Text(
                                        languageService.translate(
                                            'landing.sisterApp',
                                            'Also try our Cosmetics Checker!'),
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Consumer<LanguageService>(
                                    builder: (context, languageService, child) {
                                      return Text(
                                        languageService.translate(
                                            'landing.sameLogin',
                                            'Use the same login for both apps'),
                                        style: TextStyle(
                                          fontSize: isTablet ? 13 : 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return Text(
                              languageService.translate(
                                  'landing.cosmeticsDescription',
                                  'Scan cosmetics and personal care products to detect harmful chemicals in makeup, skincare, and beauty products.'),
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Download Button
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 52 : 48,
                          child: ElevatedButton(
                            onPressed: _launchCosmeticsApp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getStoreIcon(),
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Consumer<LanguageService>(
                                  builder: (context, languageService, child) {
                                    return Text(
                                      '${languageService.translate('landing.downloadFrom', 'Download from')} ${_getStoreName()}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 15 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Features list
                        Row(
                          children: [
                            Expanded(
                              child: _buildCosmeticsFeature(
                                Icons.face_retouching_natural,
                                context.read<LanguageService>().translate(
                                    'landing.cosmeticsFeature1',
                                    'Makeup Scanner'),
                                isTablet,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCosmeticsFeature(
                                Icons.health_and_safety,
                                context.read<LanguageService>().translate(
                                    'landing.cosmeticsFeature2',
                                    'Safety Ratings'),
                                isTablet,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCosmeticsFeature(
                                Icons.local_pharmacy,
                                context.read<LanguageService>().translate(
                                    'landing.cosmeticsFeature3',
                                    'Skincare Analysis'),
                                isTablet,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCosmeticsFeature(IconData icon, String text, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF8B5CF6),
            size: isTablet ? 20 : 18,
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 11 : 10,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
