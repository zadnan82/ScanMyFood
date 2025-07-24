// lib/Home/LandingScannerPage.dart - Teaser version with blurred results
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scanmyfood/Joining/signin.dart';
import 'package:scanmyfood/Joining/signup.dart';
import 'package:scanmyfood/services/language_service.dart';

class LandingScannerPage extends StatefulWidget {
  const LandingScannerPage({Key? key}) : super(key: key);

  @override
  State<LandingScannerPage> createState() => _LandingScannerPageState();
}

class _LandingScannerPageState extends State<LandingScannerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  XFile? imageFile;
  bool textScanning = false;
  String scannedText = "";
  bool hasScanned = false;
  List<String> mockDetectedIngredients = [];
  List<String> mockHarmfulIngredients = [];

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
    super.dispose();
  }

  Future<void> getRecognisedText(XFile image) async {
    setState(() {
      textScanning = true;
      scannedText = "";
      hasScanned = false;
      mockDetectedIngredients = [];
      mockHarmfulIngredients = [];
    });

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textDetector = TextRecognizer();
      final RecognizedText recognisedText =
          await textDetector.processImage(inputImage);
      await textDetector.close();

      String totalText = "";
      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          totalText = "$totalText ${line.text}";
        }
      }

      // Simulate ingredient analysis with mock data
      await Future.delayed(const Duration(seconds: 1));

      // Generate mock results based on detected text
      _generateMockResults(totalText.toLowerCase());

      setState(() {
        scannedText = totalText.trim();
        hasScanned = true;
      });
    } catch (e) {
      setState(() {
        scannedText = "Error occurred while scanning";
        hasScanned = true;
      });
      debugPrint('Scanning error: $e');
    } finally {
      setState(() {
        textScanning = false;
      });
    }
  }

  void _generateMockResults(String text) {
    // Mock ingredient detection based on common food additive keywords
    final Map<String, String> commonAdditives = {
      'aspartame': 'high',
      'msg': 'medium',
      'sodium': 'medium',
      'sugar': 'low',
      'corn syrup': 'high',
      'artificial': 'medium',
      'preservative': 'medium',
      'coloring': 'low',
      'flavor': 'low',
      'nitrate': 'high',
      'sulfite': 'medium',
      'bha': 'high',
      'bht': 'high',
      'red 40': 'medium',
      'yellow 5': 'medium',
    };

    mockDetectedIngredients = [];
    mockHarmfulIngredients = [];

    // Check for keywords in scanned text
    for (String additive in commonAdditives.keys) {
      if (text.contains(additive)) {
        mockDetectedIngredients.add(additive);
        if (commonAdditives[additive] != 'low') {
          mockHarmfulIngredients.add(additive);
        }
      }
    }

    // Add some random mock ingredients if none detected
    if (mockDetectedIngredients.isEmpty && scannedText.isNotEmpty) {
      mockDetectedIngredients = ['aspartame', 'sodium benzoate', 'red 40'];
      mockHarmfulIngredients = ['aspartame', 'sodium benzoate'];
    }
  }

  Future<void> getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          imageFile = pickedImage;
        });
        await getRecognisedText(pickedImage);
      }
    } catch (e) {
      setState(() {
        imageFile = null;
        scannedText = "Error occurred while selecting image";
        hasScanned = true;
      });
      debugPrint('Image picker error: $e');
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
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Logo
                    Container(
                      width: isTablet ? 36 : 28,
                      height: isTablet ? 36 : 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                languageService.translate(
                                    'scanner.tryScanner', 'Try Our Scanner'),
                                style: TextStyle(
                                  color: const Color(0xFF0F172A),
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                languageService.translate('scanner.freePreview',
                                    'Free preview - Sign up for full results'),
                                style: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: isTablet ? 12 : 11,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                      // Scanner Interface
                      if (textScanning) ...[
                        _buildScanningInterface(isTablet),
                      ] else if (imageFile == null) ...[
                        _buildWelcomeInterface(isTablet),
                      ] else ...[
                        _buildImagePreview(isTablet),
                      ],

                      const SizedBox(height: 24),

                      // Camera Controls
                      _buildCameraControls(isTablet),

                      const SizedBox(height: 24),

                      // Results with Blur and CTA
                      if (hasScanned && scannedText.isNotEmpty) ...[
                        _buildBlurredResults(isTablet),
                        const SizedBox(height: 24),
                        _buildSignUpCTA(isTablet),
                      ],
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

  Widget _buildScanningInterface(bool isTablet) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Container(
          padding: EdgeInsets.all(isTablet ? 40 : 32),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.scanner,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                languageService.translate(
                    'scanner.analyzingIngredients', 'Analyzing ingredients...'),
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                languageService.translate('scanner.checkingDatabase',
                    'Checking our ingredient database'),
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const LinearProgressIndicator(
                backgroundColor: Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeInterface(bool isTablet) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Container(
          padding: EdgeInsets.all(isTablet ? 40 : 32),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                width: isTablet ? 80 : 70,
                height: isTablet ? 80 : 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: const Color(0xFF2563EB),
                  size: isTablet ? 40 : 35,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                languageService.translate(
                    'scanner.freePreviewTitle', 'Free Preview Scanner'),
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                languageService.translate('scanner.scanDescription',
                    'Scan any ingredient label to see our powerful analysis in action. We\'ll detect harmful additives and show you what to avoid!'),
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePreview(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(imageFile!.path),
          height: isTablet ? 250 : 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCameraControls(bool isTablet) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => getImage(ImageSource.gallery),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      languageService.translate('scanner.gallery', 'Gallery'),
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => getImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
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
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      languageService.translate('scanner.camera', 'Camera'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlurredResults(bool isTablet) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Stack(
          children: [
            // Blurred content
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
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: mockHarmfulIngredients.isNotEmpty
                              ? const Color(0xFFEF4444).withOpacity(0.1)
                              : const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          mockHarmfulIngredients.isNotEmpty
                              ? Icons.warning
                              : Icons.check_circle,
                          color: mockHarmfulIngredients.isNotEmpty
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mockHarmfulIngredients.isNotEmpty
                                  ? languageService.translate(
                                      'scanner.warningFound',
                                      'Warning: Harmful Ingredients Found!')
                                  : languageService.translate(
                                      'scanner.allClearTitle', 'All Clear!'),
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: mockHarmfulIngredients.isNotEmpty
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              '${mockDetectedIngredients.length} ${languageService.translate('scanner.ingredientsAnalyzed', 'ingredients analyzed')}',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 11,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Mock ingredient list
                  if (mockDetectedIngredients.isNotEmpty) ...[
                    Text(
                      languageService.translate('scanner.detectedIngredients',
                          'Detected Ingredients:'),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...mockDetectedIngredients.take(3).map((ingredient) {
                      final isHarmful =
                          mockHarmfulIngredients.contains(ingredient);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isHarmful
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isHarmful
                                ? const Color(0xFFEF4444).withOpacity(0.2)
                                : const Color(0xFF10B981).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isHarmful
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ingredient.toUpperCase(),
                                style: TextStyle(
                                  fontSize: isTablet ? 13 : 12,
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isHarmful)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  languageService.translate(
                                      'scanner.harmful', 'HARMFUL'),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),

            // Blur overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.8),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF2563EB), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock,
                            color: Color(0xFF2563EB),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            languageService.translate(
                                'scanner.unlockResults', 'Unlock Full Results'),
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            languageService.translate('scanner.signUpMessage',
                                'Sign up to see detailed ingredient analysis, health warnings, and personalized recommendations'),
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              color: const Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignUpCTA(bool isTablet) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Column(
          children: [
            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: isTablet ? 56 : 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUp()),
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
                      Icons.lock_open,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      languageService.translate(
                          'auth.signUpFree', 'Sign Up Free - Unlock Results'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sign In Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  languageService.translate(
                      'auth.alreadyHaveAccount', 'Already have an account? '),
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    );
                  },
                  child: Text(
                    languageService.translate('auth.signIn', 'Sign In'),
                    style: TextStyle(
                      color: const Color(0xFF2563EB),
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Benefits
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text(
                    languageService.translate('scanner.whatYouGet',
                        'What you get with a free account:'),
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefit(
                      Icons.warning_amber,
                      languageService.translate('scanner.harmfulDetection',
                          'Harmful ingredient detection'),
                      isTablet),
                  _buildBenefit(
                      Icons.health_and_safety,
                      languageService.translate(
                          'scanner.healthWarnings', 'Detailed health warnings'),
                      isTablet),
                  _buildBenefit(
                      Icons.list_alt,
                      languageService.translate('scanner.customLists',
                          'Custom ingredient blacklists'),
                      isTablet),
                  _buildBenefit(
                      Icons.translate,
                      languageService.translate(
                          'scanner.multiLanguage', 'Multi-language support'),
                      isTablet),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBenefit(IconData icon, String text, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF10B981),
            size: isTablet ? 16 : 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
