// lib/Joining/signup.dart - Updated version
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanmyfood/Joining/signin.dart';
import 'package:scanmyfood/Home/home.dart';
import 'package:scanmyfood/services/language_service.dart';

class SignUp extends StatefulWidget {
  // Make constructor const
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final LanguageService _languageService = LanguageService.instance;
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      Fluttertoast.showToast(
        msg: _languageService.translate(
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
          msg: _languageService.translate(
              'auth.accountCreated', 'Account created successfully!'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          textColor: Colors.white,
        );

        // Navigate to main app (Home with bottom navigation)
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
          errorMessage = _languageService.translate(
              'errors.weakPassword', 'The password provided is too weak.');
          break;
        case 'email-already-in-use':
          errorMessage = _languageService.translate(
              'errors.emailInUse', 'An account already exists for that email.');
          break;
        case 'invalid-email':
          errorMessage = _languageService.translate(
              'errors.invalidEmail', 'Please enter a valid email address');
          break;
        default:
          errorMessage = _languageService.translate(
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
        msg: _languageService.translate(
            'common.error', 'An unexpected error occurred'),
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
                              _languageService.translate(
                                  'auth.createAccount', 'Create Account'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate('auth.joinUs',
                                  'Join us to start protecting your health with smart ingredient scanning'),
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
                                const SizedBox(height: 24),

                                // Name Fields Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _firstNameController,
                                        style: TextStyle(
                                            fontSize: isTablet ? 16 : 14),
                                        decoration: InputDecoration(
                                          labelText: _languageService.translate(
                                              'auth.firstName', 'First Name'),
                                          labelStyle: TextStyle(
                                            color: const Color(0xFF64748B),
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF6366F1),
                                                width: 2),
                                          ),
                                          contentPadding: EdgeInsets.all(
                                              isTablet ? 16 : 12),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return _languageService.translate(
                                                'errors.firstNameRequired',
                                                'First name is required');
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _lastNameController,
                                        style: TextStyle(
                                            fontSize: isTablet ? 16 : 14),
                                        decoration: InputDecoration(
                                          labelText: _languageService.translate(
                                              'auth.lastName', 'Last Name'),
                                          labelStyle: TextStyle(
                                            color: const Color(0xFF64748B),
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF6366F1),
                                                width: 2),
                                          ),
                                          contentPadding: EdgeInsets.all(
                                              isTablet ? 16 : 12),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return _languageService.translate(
                                                'errors.lastNameRequired',
                                                'Last name is required');
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style:
                                      TextStyle(fontSize: isTablet ? 16 : 14),
                                  decoration: InputDecoration(
                                    labelText: _languageService.translate(
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
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF6366F1), width: 2),
                                    ),
                                    contentPadding:
                                        EdgeInsets.all(isTablet ? 16 : 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _languageService.translate(
                                          'errors.emailRequired',
                                          'Email is required');
                                    }
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return _languageService.translate(
                                          'errors.invalidEmail',
                                          'Please enter a valid email address');
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style:
                                      TextStyle(fontSize: isTablet ? 16 : 14),
                                  decoration: InputDecoration(
                                    labelText: _languageService.translate(
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
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF6366F1), width: 2),
                                    ),
                                    contentPadding:
                                        EdgeInsets.all(isTablet ? 16 : 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _languageService.translate(
                                          'errors.passwordRequired',
                                          'Password is required');
                                    }
                                    if (value.length < 6) {
                                      return _languageService.translate(
                                          'errors.passwordTooShort',
                                          'Password must be at least 6 characters');
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Confirm Password Field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  style:
                                      TextStyle(fontSize: isTablet ? 16 : 14),
                                  decoration: InputDecoration(
                                    labelText: _languageService.translate(
                                        'auth.confirmPassword',
                                        'Confirm Password'),
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
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF64748B),
                                        size: isTablet ? 20 : 18,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF6366F1), width: 2),
                                    ),
                                    contentPadding:
                                        EdgeInsets.all(isTablet ? 16 : 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _languageService.translate(
                                          'errors.confirmPasswordRequired',
                                          'Please confirm your password');
                                    }
                                    if (value != _passwordController.text) {
                                      return _languageService.translate(
                                          'errors.passwordsDoNotMatch',
                                          'Passwords do not match');
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Terms Checkbox
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _acceptTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptTerms = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF6366F1),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _languageService.translate(
                                            'auth.termsConditions',
                                            'I agree to the Terms and Conditions'),
                                        style: TextStyle(
                                          color: const Color(0xFF64748B),
                                          fontSize: isTablet ? 14 : 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Sign Up Button
                                Container(
                                  width: double.infinity,
                                  height: isTablet ? 56 : 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6366F1)
                                            .withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
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
                                        : Text(
                                            _languageService.translate(
                                                'auth.createAccount',
                                                'Create Account'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isTablet ? 16 : 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),

                                const Spacer(),

                                // Sign In Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _languageService.translate(
                                          'auth.alreadyHaveAccount',
                                          'Already have an account? '),
                                      style: TextStyle(
                                        color: const Color(0xFF64748B),
                                        fontSize: isTablet ? 14 : 12,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignIn()),
                                        );
                                      },
                                      child: Text(
                                        _languageService.translate(
                                            'auth.signIn', 'Sign In'),
                                        style: TextStyle(
                                          color: const Color(0xFF6366F1),
                                          fontSize: isTablet ? 14 : 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
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
