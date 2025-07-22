// lib/Joining/signout.dart - Fixed version with proper back navigation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanmyfood/Home/landingpage.dart';
import 'package:scanmyfood/services/language_service.dart';

class SignOut extends StatefulWidget {
  const SignOut({Key? key}) : super(key: key);

  @override
  State<SignOut> createState() => _SignOutState();
}

class _SignOutState extends State<SignOut> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final LanguageService _languageService = LanguageService.instance;
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
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
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Fluttertoast.showToast(
          msg: _languageService.translate(
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
      Fluttertoast.showToast(
        msg: _languageService.translate(
            'errors.signOutError', 'Error signing out. Please try again.'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            _languageService.translate(
                'account.deleteAccount', 'Delete Account'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF4444),
            ),
          ),
          content: Text(
            _languageService.translate('account.deleteWarning',
                'Once you delete your account, there is no going back. Please be certain.'),
            style: const TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                _languageService.translate('common.cancel', 'Cancel'),
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
                _languageService.translate('common.delete', 'Delete'),
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
            msg: _languageService.translate(
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
        Fluttertoast.showToast(
          msg: _languageService.translate('errors.deleteAccountError',
              'Error deleting account. You may need to sign in again.'),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          textColor: Colors.white,
        );
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header - FIXED: Removed automaticallyImplyLeading: false
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: isTablet ? 180 : 140,
                  floating: false,
                  pinned: true,
                  // CRITICAL FIX: Allow automatic back button when needed
                  leading: Navigator.of(context).canPop()
                      ? IconButton(
                          icon: Icon(
                            Theme.of(context).platform == TargetPlatform.iOS
                                ? Icons.arrow_back_ios
                                : Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      : null,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
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
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: isTablet ? 32 : 28,
                                  height: isTablet ? 32 : 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      'assets/app_logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.account_circle,
                                  color: Colors.white,
                                  size: isTablet ? 28 : 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate(
                                  'account.accountSettings',
                                  'Account Settings'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _languageService.translate(
                                  'account.manageAccount',
                                  'Manage your account and data'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isTablet ? 18 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Rest of the existing code remains the same...
                // User Info Card
                if (_currentUser != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withOpacity(0.1),
                              const Color(0xFF059669).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: const Color(0xFF10B981),
                                size: isTablet ? 28 : 24,
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
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _languageService.translate(
                                        'account.loggedInActive',
                                        'Logged in and active'),
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: const Color(0xFF10B981),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_currentUser?.email != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentUser!.email!,
                                      style: TextStyle(
                                        fontSize: isTablet ? 12 : 10,
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
                    ),
                  ),
                ],

                // Account Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          Text(
                            _languageService.translate(
                                'account.accountActions', 'Account Actions'),
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _languageService.translate('account.chooseAction',
                                'Choose what you\'d like to do with your account'),
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign Out Button
                          Container(
                            width: double.infinity,
                            height: isTablet ? 60 : 52,
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
                                  color:
                                      const Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signOut,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
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
                                          size: isTablet ? 24 : 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _languageService.translate(
                                              'account.signOut', 'Sign Out'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 16 : 14,
                                            fontWeight: FontWeight.bold,
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
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Danger Zone
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                          width: 1,
                        ),
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
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: const Color(0xFFEF4444),
                                size: isTablet ? 24 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _languageService.translate(
                                    'account.dangerZone', 'Danger Zone'),
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _languageService.translate('account.deleteWarning',
                                'Once you delete your account, there is no going back. Please be certain.'),
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Delete Account Button
                          Container(
                            width: double.infinity,
                            height: isTablet ? 52 : 44,
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
                                    size: isTablet ? 20 : 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _languageService.translate(
                                        'account.deleteAccount',
                                        'Delete Account'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 14 : 12,
                                      fontWeight: FontWeight.bold,
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
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
