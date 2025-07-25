// lib/Joining/signout.dart - Simplified clean version
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:scanmyfood/Home/landingpage.dart';
import 'package:scanmyfood/services/language_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SignOut extends StatefulWidget {
  const SignOut({Key? key}) : super(key: key);

  @override
  State<SignOut> createState() => _SignOutState();
}

class _SignOutState extends State<SignOut> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getCurrentUser();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _signOut() async {
    final languageService = context.read<LanguageService>();

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Fluttertoast.showToast(
          msg: languageService.translate(
              'auth.signedOut', 'Successfully signed out!'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          textColor: Colors.white,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: languageService.translate(
              'errors.signOutError', 'Error signing out. Please try again.'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final languageService = context.read<LanguageService>();

    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            languageService.translate(
                'account.deleteAccount', 'Delete Account'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF4444),
            ),
          ),
          content: Text(
            languageService.translate('account.deleteWarning',
                'Once you delete your account, there is no going back. Please be certain.'),
            style: const TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                languageService.translate('common.cancel', 'Cancel'),
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                languageService.translate('common.delete', 'Delete'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await _currentUser?.delete();

        if (mounted) {
          Fluttertoast.showToast(
            msg: languageService.translate(
                'account.accountDeleted', 'Account deleted successfully'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            textColor: Colors.white,
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: languageService.translate('errors.deleteAccountError',
                'Error deleting account. You may need to sign in again.'),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            textColor: Colors.white,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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
          child: Column(
            children: [
              // Clean Header
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      width: isTablet ? 40 : 32,
                      height: isTablet ? 40 : 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/app_logo.png',
                          fit: BoxFit.cover,
                        ),
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
                                    'account.accountSettings',
                                    'Account Settings'),
                                style: TextStyle(
                                  color: const Color(0xFF0F172A),
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                languageService.translate(
                                    'account.manageAccount',
                                    'Manage your account and data'),
                                style: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: isTablet ? 14 : 12,
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

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  child: Column(
                    children: [
                      // User Info Card
                      if (_currentUser != null) ...[
                        Container(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: const Color(0xFF10B981),
                                  size: isTablet ? 24 : 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentUser?.displayName ??
                                          _currentUser?.email ??
                                          'User',
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Consumer<LanguageService>(
                                      builder:
                                          (context, languageService, child) {
                                        return Text(
                                          languageService.translate(
                                              'account.loggedInActive',
                                              'Logged in and active'),
                                          style: TextStyle(
                                            fontSize: isTablet ? 12 : 11,
                                            color: const Color(0xFF10B981),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                    ),
                                    if (_currentUser?.email != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        _currentUser!.email!,
                                        style: TextStyle(
                                          fontSize: isTablet ? 11 : 10,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Account Actions
                      Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<LanguageService>(
                              builder: (context, languageService, child) {
                                return Text(
                                  languageService.translate(
                                      'account.accountActions',
                                      'Account Actions'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Consumer<LanguageService>(
                              builder: (context, languageService, child) {
                                return Text(
                                  languageService.translate(
                                      'account.chooseAction',
                                      'Choose what you\'d like to do with your account'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Sign Out Button
                            SizedBox(
                              width: double.infinity,
                              height: isTablet ? 56 : 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signOut,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.logout,
                                            color: Colors.white,
                                            size: isTablet ? 20 : 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Consumer<LanguageService>(
                                            builder: (context, languageService,
                                                child) {
                                              return Text(
                                                languageService.translate(
                                                    'account.signOut',
                                                    'Sign Out'),
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Legal Links Section
                      Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<LanguageService>(
                              builder: (context, languageService, child) {
                                return Text(
                                  languageService.translate(
                                      'account.legalInformation',
                                      'Legal Information'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Privacy Policy Link
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse(
                                    'https://portfolio-zainab-adnan.vercel.app/food-privacy');
                                try {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: context
                                        .read<LanguageService>()
                                        .translate('errors.cantOpenLink',
                                            'Could not open link'),
                                    backgroundColor: const Color(0xFFEF4444),
                                    textColor: Colors.white,
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(isTablet ? 12 : 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.privacy_tip_outlined,
                                      color: Color(0xFF2563EB),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Consumer<LanguageService>(
                                        builder:
                                            (context, languageService, child) {
                                          return Text(
                                            languageService.translate(
                                                'auth.privacyPolicy',
                                                'Privacy Policy'),
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 13,
                                              color: const Color(0xFF2563EB),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const Icon(
                                      Icons.open_in_new,
                                      color: Color(0xFF64748B),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Terms & Conditions Link
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse(
                                    'https://portfolio-zainab-adnan.vercel.app/food-terms');
                                try {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: context
                                        .read<LanguageService>()
                                        .translate('errors.cantOpenLink',
                                            'Could not open link'),
                                    backgroundColor: const Color(0xFFEF4444),
                                    textColor: Colors.white,
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(isTablet ? 12 : 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.article_outlined,
                                      color: Color(0xFF2563EB),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Consumer<LanguageService>(
                                        builder:
                                            (context, languageService, child) {
                                          return Text(
                                            languageService.translate(
                                                'auth.termsAndConditions',
                                                'Terms & Conditions'),
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 13,
                                              color: const Color(0xFF2563EB),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const Icon(
                                      Icons.open_in_new,
                                      color: Color(0xFF64748B),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Danger Zone
                      Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  color: const Color(0xFFEF4444),
                                  size: isTablet ? 20 : 18,
                                ),
                                const SizedBox(width: 8),
                                Consumer<LanguageService>(
                                  builder: (context, languageService, child) {
                                    return Text(
                                      languageService.translate(
                                          'account.dangerZone', 'Danger Zone'),
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFEF4444),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Consumer<LanguageService>(
                              builder: (context, languageService, child) {
                                return Text(
                                  languageService.translate(
                                      'account.deleteWarning',
                                      'Once you delete your account, there is no going back. Please be certain.'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Delete Account Button
                            SizedBox(
                              width: double.infinity,
                              height: isTablet ? 48 : 44,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _deleteAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_forever,
                                      color: Colors.white,
                                      size: isTablet ? 18 : 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Consumer<LanguageService>(
                                      builder:
                                          (context, languageService, child) {
                                        return Text(
                                          languageService.translate(
                                              'account.deleteAccount',
                                              'Delete Account'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 14 : 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
