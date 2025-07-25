// lib/Joining/signin.dart - Complete clean version
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:scanmyfood/Joining/signup.dart';
import 'package:scanmyfood/Home/home.dart';
import 'package:scanmyfood/services/language_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final languageService = context.read<LanguageService>();
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );

        Fluttertoast.showToast(
          msg: languageService.translate(
              'auth.signInSuccess', 'Successfully signed in!'),
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
          errorMessage = languageService.translate(
              'errors.userNotFound', 'No user found for that email.');
          break;
        case 'wrong-password':
          errorMessage = languageService.translate(
              'errors.wrongPassword', 'Wrong password provided.');
          break;
        case 'invalid-email':
          errorMessage = languageService.translate(
              'errors.invalidEmail', 'Please enter a valid email address');
          break;
        case 'user-disabled':
          errorMessage = languageService.translate(
              'errors.userDisabled', 'This account has been disabled.');
          break;
        default:
          errorMessage = languageService.translate(
              'errors.signInError', 'An error occurred. Please try again.');
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
        msg: context
            .read<LanguageService>()
            .translate('common.error', 'An unexpected error occurred'),
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
    final languageService = context.read<LanguageService>();

    if (_emailController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: languageService.translate(
            'errors.emailRequired', 'Please enter your email address'),
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
        msg: languageService.translate('auth.resetPasswordSent',
            'Password reset email sent! Check your inbox and spam folder.'),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        textColor: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = languageService.translate(
              'errors.userNotFound', 'No user found for that email.');
          break;
        case 'invalid-email':
          errorMessage = languageService.translate(
              'errors.invalidEmail', 'Please enter a valid email address');
          break;
        default:
          errorMessage = languageService.translate('errors.resetPasswordError',
              'Failed to send reset email. Please try again.');
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
                  // Header Section
                  SizedBox(height: isTablet ? 40 : 20),

                  // Logo and Back Button Row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  SizedBox(height: isTablet ? 40 : 20),

                  // Logo Section
                  Container(
                    width: isTablet ? 80 : 64,
                    height: isTablet ? 80 : 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/app_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 32 : 24),

                  // Title Section
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.translate('auth.signIn', 'Sign In'),
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isTablet ? 12 : 8),

                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.translate('auth.welcomeBack',
                            'Welcome back! Please sign in to your account'),
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  SizedBox(height: isTablet ? 48 : 40),

                  // Form Section
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: isTablet ? 16 : 14),
                              decoration: InputDecoration(
                                labelText: languageService.translate(
                                    'auth.email', 'Email Address'),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: isTablet ? 14 : 12,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: const Color(0xFF64748B),
                                  size: isTablet ? 20 : 18,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF2563EB), width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFEF4444), width: 2),
                                ),
                                contentPadding:
                                    EdgeInsets.all(isTablet ? 16 : 14),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return languageService.translate(
                                      'errors.emailRequired',
                                      'Email is required');
                                }
                                if (!RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                    .hasMatch(value)) {
                                  return languageService.translate(
                                      'errors.invalidEmail',
                                      'Please enter a valid email address');
                                }
                                return null;
                              },
                            );
                          },
                        ),

                        SizedBox(height: isTablet ? 20 : 16),

                        // Password Field
                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(fontSize: isTablet ? 16 : 14),
                              decoration: InputDecoration(
                                labelText: languageService.translate(
                                    'auth.password', 'Password'),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: isTablet ? 14 : 12,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outlined,
                                  color: const Color(0xFF64748B),
                                  size: isTablet ? 20 : 18,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF64748B),
                                    size: isTablet ? 20 : 18,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF2563EB), width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFEF4444), width: 2),
                                ),
                                contentPadding:
                                    EdgeInsets.all(isTablet ? 16 : 14),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return languageService.translate(
                                      'errors.passwordRequired',
                                      'Password is required');
                                }
                                if (value.length < 6) {
                                  return languageService.translate(
                                      'errors.passwordTooShort',
                                      'Password must be at least 6 characters');
                                }
                                return null;
                              },
                            );
                          },
                        ),

                        SizedBox(height: isTablet ? 16 : 12),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return TextButton(
                                onPressed: _resetPassword,
                                child: Text(
                                  languageService.translate(
                                      'auth.forgotPassword',
                                      'Forgot Password?'),
                                  style: TextStyle(
                                    color: const Color(0xFF2563EB),
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: isTablet ? 32 : 24),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 56 : 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Consumer<LanguageService>(
                                    builder: (context, languageService, child) {
                                      return Text(
                                        languageService.translate(
                                            'auth.signIn', 'Sign In'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),

                        SizedBox(height: isTablet ? 32 : 24),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Consumer<LanguageService>(
                              builder: (context, languageService, child) {
                                return Text(
                                  languageService.translate(
                                      'auth.dontHaveAccount',
                                      'Don\'t have an account? '),
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
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SignUp()),
                                    );
                                  },
                                  child: Text(
                                    languageService.translate(
                                        'auth.signUp', 'Sign Up'),
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

                        const SizedBox(height: 16),

                        // Privacy Policy Link
                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse(
                                    'https://portfolio-zainab-adnan.vercel.app/food-privacy');
                                try {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: languageService.translate(
                                        'errors.cantOpenLink',
                                        'Could not open link'),
                                    backgroundColor: const Color(0xFFEF4444),
                                    textColor: Colors.white,
                                  );
                                }
                              },
                              child: Text(
                                languageService.translate(
                                    'auth.readPrivacyPolicy',
                                    'Read our Privacy Policy'),
                                style: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: isTablet ? 12 : 11,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isTablet ? 40 : 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
