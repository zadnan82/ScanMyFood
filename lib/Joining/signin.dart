// lib/Joining/signin.dart - Complete Fixed Version
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanmyfood/Joining/signup.dart';
import 'package:scanmyfood/Home/home.dart';
import 'package:scanmyfood/services/language_service.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final LanguageService _languageService = LanguageService.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Navigate to main app (Home with bottom navigation)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
        
        Fluttertoast.showToast(
          msg: _languageService.translate('auth.signInSuccess', 'Successfully signed in!'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          textColor: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = _languageService.translate('errors.userNotFound', 'No user found for that email.');
          break;
        case 'wrong-password':
          errorMessage = _languageService.translate('errors.wrongPassword', 'Wrong password provided.');
          break;
        case 'invalid-email':
          errorMessage = _languageService.translate('errors.invalidEmail', 'Please enter a valid email address');
          break;
        case 'user-disabled':
          errorMessage = _languageService.translate('errors.userDisabled', 'This account has been disabled.');
          break;
        default:
          errorMessage = _languageService.translate('errors.signInError', 'An error occurred. Please try again.');
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: _languageService.translate('common.error', 'An unexpected error occurred'),
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

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: _languageService.translate('errors.emailRequired', 'Please enter your email address'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        textColor: Colors.white,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      Fluttertoast.showToast(
        msg: _languageService.translate('auth.resetPasswordSent', 'Password reset email sent!'),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        textColor: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = _languageService.translate('errors.userNotFound', 'No user found for that email.');
          break;
        case 'invalid-email':
          errorMessage = _languageService.translate('errors.invalidEmail', 'Please enter a valid email address');
          break;
        default:
          errorMessage = _languageService.translate('errors.resetPasswordError', 'Failed to send reset email. Please try again.');
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
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
                      // Header
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
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: isTablet ? 100 : 80,
                              height: isTablet ? 100 : 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/app_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _languageService.translate('auth.signIn', 'Sign In'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate('auth.welcomeBack', 'Welcome back! Please sign in to your account'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isTablet ? 18 : 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Form Section
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 32 : 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const SizedBox(height: 32),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                                  decoration: InputDecoration(
                                    labelText: _languageService.translate('auth.email', 'Email Address'),
                                    labelStyle: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: const Color(0xFF64748B),
                                      size: isTablet ? 24 : 20,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
                                    ),
                                    contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _languageService.translate('errors.emailRequired', 'Email is required');
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return _languageService.translate('errors.invalidEmail', 'Please enter a valid email address');
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                                  decoration: InputDecoration(
                                    labelText: _languageService.translate('auth.password', 'Password'),
                                    labelStyle: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outlined,
                                      color: const Color(0xFF64748B),
                                      size: isTablet ? 24 : 20,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: const Color(0xFF64748B),
                                        size: isTablet ? 24 : 20,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
                                    ),
                                    contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _languageService.translate('errors.passwordRequired', 'Password is required');
                                    }
                                    if (value.length < 6) {
                                      return _languageService.translate('errors.passwordTooShort', 'Password must be at least 6 characters');
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _resetPassword,
                                    child: Text(
                                      _languageService.translate('auth.forgotPassword', 'Forgot Password?'),
                                      style: TextStyle(
                                        color: const Color(0xFF6366F1),
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Sign In Button
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
                                        color: const Color(0xFF6366F1).withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signIn,
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
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _languageService.translate('auth.signIn', 'Sign In'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isTablet ? 18 : 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),

                                const Spacer(),

                                // Sign Up Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _languageService.translate('auth.dontHaveAccount', 'Don\'t have an account? '),
                                      style: TextStyle(
                                        color: const Color(0xFF64748B),
                                        fontSize: isTablet ? 16 : 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const SignUp()),
                                        );
                                      },
                                      child: Text(
                                        _languageService.translate('auth.signUp', 'Sign Up'),
                                        style: TextStyle(
                                          color: const Color(0xFF6366F1),
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
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
}