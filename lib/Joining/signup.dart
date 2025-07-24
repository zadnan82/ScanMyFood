// lib/Joining/signup.dart - Complete clean version
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:scanmyfood/Joining/signin.dart';
import 'package:scanmyfood/Home/home.dart';
import 'package:scanmyfood/services/language_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final languageService = context.read<LanguageService>();

    if (!_acceptTerms) {
      Fluttertoast.showToast(
        msg: languageService.translate(
            'errors.acceptTerms', 'Please accept the terms and conditions'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: languageService.translate(
              'auth.accountCreated', 'Account created successfully!'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          textColor: Colors.white,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = languageService.translate(
              'errors.weakPassword', 'The password provided is too weak.');
          break;
        case 'email-already-in-use':
          errorMessage = languageService.translate(
              'errors.emailInUse', 'An account already exists for that email.');
          break;
        case 'invalid-email':
          errorMessage = languageService.translate(
              'errors.invalidEmail', 'Please enter a valid email address');
          break;
        default:
          errorMessage = languageService.translate(
              'errors.signUpError', 'An error occurred. Please try again.');
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
                  SizedBox(height: isTablet ? 20 : 10),

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

                  SizedBox(height: isTablet ? 20 : 10),

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

                  SizedBox(height: isTablet ? 24 : 16),

                  // Title Section
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.translate(
                            'auth.createAccount', 'Create Account'),
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isTablet ? 8 : 6),

                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.translate('auth.joinUs',
                            'Join us to start protecting your health'),
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  SizedBox(height: isTablet ? 32 : 24),

                  // Form Section
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Fields Row
                        Row(
                          children: [
                            Expanded(
                              child: Consumer<LanguageService>(
                                builder: (context, languageService, child) {
                                  return TextFormField(
                                    controller: _firstNameController,
                                    style:
                                        TextStyle(fontSize: isTablet ? 14 : 12),
                                    decoration: InputDecoration(
                                      labelText: languageService.translate(
                                          'auth.firstName', 'First Name'),
                                      labelStyle: TextStyle(
                                        color: const Color(0xFF64748B),
                                        fontSize: isTablet ? 12 : 11,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF2563EB), width: 2),
                                      ),
                                      contentPadding:
                                          EdgeInsets.all(isTablet ? 14 : 12),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return languageService.translate(
                                            'errors.firstNameRequired',
                                            'Required');
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Consumer<LanguageService>(
                                builder: (context, languageService, child) {
                                  return TextFormField(
                                    controller: _lastNameController,
                                    style:
                                        TextStyle(fontSize: isTablet ? 14 : 12),
                                    decoration: InputDecoration(
                                      labelText: languageService.translate(
                                          'auth.lastName', 'Last Name'),
                                      labelStyle: TextStyle(
                                        color: const Color(0xFF64748B),
                                        fontSize: isTablet ? 12 : 11,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF2563EB), width: 2),
                                      ),
                                      contentPadding:
                                          EdgeInsets.all(isTablet ? 14 : 12),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return languageService.translate(
                                            'errors.lastNameRequired',
                                            'Required');
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 16 : 12),

                        // Email Field
                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: isTablet ? 14 : 12),
                              decoration: InputDecoration(
                                labelText: languageService.translate(
                                    'auth.email', 'Email Address'),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: isTablet ? 12 : 11,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: const Color(0xFF64748B),
                                  size: isTablet ? 18 : 16,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF2563EB), width: 2),
                                ),
                                contentPadding:
                                    EdgeInsets.all(isTablet ? 14 : 12),
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

                        SizedBox(height: isTablet ? 16 : 12),

                        // Password Field
                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(fontSize: isTablet ? 14 : 12),
                              decoration: InputDecoration(
                                labelText: languageService.translate(
                                    'auth.password', 'Password'),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: isTablet ? 12 : 11,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outlined,
                                  color: const Color(0xFF64748B),
                                  size: isTablet ? 18 : 16,
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
                                    size: isTablet ? 18 : 16,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF2563EB), width: 2),
                                ),
                                contentPadding:
                                    EdgeInsets.all(isTablet ? 14 : 12),
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

                        // Confirm Password Field
                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: TextStyle(fontSize: isTablet ? 14 : 12),
                              decoration: InputDecoration(
                                labelText: languageService.translate(
                                    'auth.confirmPassword', 'Confirm Password'),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: isTablet ? 12 : 11,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outlined,
                                  color: const Color(0xFF64748B),
                                  size: isTablet ? 18 : 16,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF64748B),
                                    size: isTablet ? 18 : 16,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF2563EB), width: 2),
                                ),
                                contentPadding:
                                    EdgeInsets.all(isTablet ? 14 : 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return languageService.translate(
                                      'errors.confirmPasswordRequired',
                                      'Please confirm your password');
                                }
                                if (value != _passwordController.text) {
                                  return languageService.translate(
                                      'errors.passwordsDoNotMatch',
                                      'Passwords do not match');
                                }
                                return null;
                              },
                            );
                          },
                        ),

                        SizedBox(height: isTablet ? 16 : 12),

                        // Terms and Privacy Section
                        Column(
                          children: [
                            // Terms Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: isTablet ? 0.9 : 0.8,
                                  child: Checkbox(
                                    value: _acceptTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _acceptTerms = value ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFF2563EB),
                                  ),
                                ),
                                Expanded(
                                  child: Consumer<LanguageService>(
                                    builder: (context, languageService, child) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _acceptTerms = !_acceptTerms;
                                          });
                                        },
                                        child: Text.rich(
                                          TextSpan(
                                            text: languageService.translate(
                                                'auth.iAgreeToThe',
                                                'I agree to the '),
                                            style: TextStyle(
                                              color: const Color(0xFF64748B),
                                              fontSize: isTablet ? 12 : 11,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: languageService.translate(
                                                    'auth.termsAndConditions',
                                                    'Terms & Conditions'),
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFF2563EB),
                                                  fontSize: isTablet ? 12 : 11,
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () async {
                                                        final uri = Uri.parse(
                                                            'https://www.zadnan.com/food-terms');
                                                        try {
                                                          await launchUrl(uri,
                                                              mode: LaunchMode
                                                                  .externalApplication);
                                                        } catch (e) {
                                                          Fluttertoast
                                                              .showToast(
                                                            msg: languageService
                                                                .translate(
                                                                    'errors.cantOpenLink',
                                                                    'Could not open link'),
                                                            backgroundColor:
                                                                const Color(
                                                                    0xFFEF4444),
                                                            textColor:
                                                                Colors.white,
                                                          );
                                                        }
                                                      },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Privacy Policy Link
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Consumer<LanguageService>(
                                builder: (context, languageService, child) {
                                  return GestureDetector(
                                    onTap: () async {
                                      final uri = Uri.parse(
                                          'https://www.zadnan.com/food-privacy');
                                      try {
                                        await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                          msg: languageService.translate(
                                              'errors.cantOpenLink',
                                              'Could not open link'),
                                          backgroundColor:
                                              const Color(0xFFEF4444),
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 32.0),
                                      child: Text(
                                        languageService.translate(
                                            'auth.readPrivacyPolicy',
                                            'Read our Privacy Policy'),
                                        style: TextStyle(
                                          color: const Color(0xFF2563EB),
                                          fontSize: isTablet ? 11 : 10,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 24 : 20),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 52 : 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
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
                                            'auth.createAccount',
                                            'Create Account'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 14 : 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),

                        SizedBox(height: isTablet ? 24 : 20),

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
                                    fontSize: isTablet ? 12 : 11,
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
                                          builder: (context) => const SignIn()),
                                    );
                                  },
                                  child: Text(
                                    languageService.translate(
                                        'auth.signIn', 'Sign In'),
                                    style: TextStyle(
                                      color: const Color(0xFF2563EB),
                                      fontSize: isTablet ? 12 : 11,
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
                  ),

                  SizedBox(height: isTablet ? 20 : 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
