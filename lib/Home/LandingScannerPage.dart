// lib/Home/LandingScannerPage.dart - Scanner page for unsigned users with back navigation
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../services/language_service.dart';

class LandingScannerPage extends StatefulWidget {
  const LandingScannerPage({Key? key}) : super(key: key);

  @override
  State<LandingScannerPage> createState() => _LandingScannerPageState();
}

class _LandingScannerPageState extends State<LandingScannerPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final LanguageService _languageService = LanguageService.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLanguageService();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
    super.dispose();
  }

  // Scanning variables
  XFile? imageFile;
  int counter = 0;
  bool textScanning = false;
  bool warning = false;
  bool showExplanations = false;
  String message = "";
  List<String> words = [];
  String dangerousItemsDetected = "";
  Map<String, Map<String, dynamic>> detectedItems = {};
  bool starting = false;

  String _fixCommonOCRMistakes(String text) {
    String fixed = text.toLowerCase();

    // Add language-specific character fixes
    switch (_languageService.currentLanguageCode) {
      case 'sv':
        fixed = fixed
            .replaceAll('ä', 'a')
            .replaceAll('ö', 'o')
            .replaceAll('å', 'a');
        break;
      case 'es':
        fixed = fixed.replaceAll('ñ', 'n').replaceAll('ü', 'u');
        break;
    }

    // Common fixes for all languages
    fixed = fixed
        .replaceAll('š', 's')
        .replaceAll('ó', 'o')
        .replaceAll('à', 'a')
        .replaceAll('è', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('ù', 'u')
        .replaceAll('arficialflavor', 'artificial flavor')
        .replaceAll('artifical', 'artificial');

    return fixed;
  }

  void getRecognisedText(XFile image) async {
    words = [];
    dangerousItemsDetected = "";
    detectedItems = {};
    counter = 0;
    textScanning = false;
    message = "";
    warning = false;
    var totalText = "";

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textDetector = TextRecognizer();
      RecognizedText recognisedText =
          await textDetector.processImage(inputImage);
      await textDetector.close();

      RegExp splitter = RegExp(r'[:,\.\;\-/[\](){}<>!@#$%^&*+=|\~`/?\d]');

      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          String lineText = line.text;
          totalText = totalText + " " + lineText;
        }
      }

      words = totalText.split(splitter);
      String fixedText = _fixCommonOCRMistakes(totalText);
      String cleanedText = fixedText.replaceAll(RegExp(r'[^\w\s]'), ' ');

      // Use language service to get current ingredients
      final currentIngredients = _languageService.ingredients;
      final harmfulIngredients = _languageService.harmfulIngredientKeys;

      // Enhanced ingredient detection logic
      for (String ingredientKey in harmfulIngredients) {
        final ingredientData = currentIngredients[ingredientKey];
        if (ingredientData == null) continue;

        String ingredientName = ingredientData['name'] ?? ingredientKey;
        bool found = false;
        String lowerKey = ingredientKey.toLowerCase();

        if (cleanedText.contains(lowerKey)) {
          if (!lowerKey.contains(' ') && !lowerKey.contains('-')) {
            List<String> cleanWords = cleanedText.split(RegExp(r'\s+'));
            bool exactWordMatch = false;

            for (String word in cleanWords) {
              String cleanWord = word.toLowerCase().trim();
              cleanWord = cleanWord.replaceAll(RegExp(r'[^\w]'), '');

              if (cleanWord == lowerKey) {
                if (lowerKey.startsWith("red") &&
                    word.toLowerCase().contains("reduced")) {
                  continue;
                }
                exactWordMatch = true;
                break;
              }
            }
            found = exactWordMatch;
          } else {
            found = true;
          }
        } else {
          List<String> keyWords = lowerKey.split(RegExp(r'[\s\-_]+'));
          if (keyWords.length > 1) {
            bool exactPhraseFound = cleanedText.contains(lowerKey);
            if (exactPhraseFound) {
              bool containsRed = keyWords.any((word) => word == "red");
              if (containsRed && cleanedText.contains("reduced")) {
                found = false;
              } else {
                found = true;
              }
            }
          }

          // Special handling for various oils and compounds
          if (lowerKey == "enriched flour" &&
              cleanedText.contains("enriched") &&
              cleanedText.contains("flour")) {
            found = true;
          }

          if (lowerKey.contains(" oil") &&
              cleanedText.contains(lowerKey.split(" ")[0]) &&
              cleanedText.contains("oil")) {
            found = true;
          }

          if (lowerKey.contains("red") && cleanedText.contains("reduced")) {
            found = false;
          }
        }

        if (found && !detectedItems.containsKey(ingredientKey)) {
          warning = true;
          counter++;
          detectedItems[ingredientKey] =
              Map<String, dynamic>.from(ingredientData);
          dangerousItemsDetected += " • $ingredientName\n";
        }
      }

      starting = true;
    } catch (e) {
      message = _languageService.translate(
          "errors.scanningError", "Error occurred while scanning");
      debugPrint('Scanning error: $e');
    } finally {
      if (mounted) {
        setState(() {
          textScanning = false;
        });
      }
    }
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          textScanning = true;
          imageFile = pickedImage;
        });
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      setState(() {
        textScanning = false;
        imageFile = null;
        message = _languageService.translate(
            "errors.imagePickerError", "Error occurred while selecting image");
      });
      debugPrint('Image picker error: $e');
    }
  }

  void _showIngredientDetails(
      String ingredientKey, Map<String, dynamic> details) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: details['severity'] == 'high'
                          ? const Color(0xFFEF4444).withOpacity(0.1)
                          : const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: details['severity'] == 'high'
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF59E0B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details['name'] ?? ingredientKey,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: details['severity'] == 'high'
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _languageService.translate(
                                'ingredientDetails.${details['severity'] ?? 'medium'}Risk',
                                '${details['severity'] ?? 'MEDIUM'} RISK'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (details['description'] != null) ...[
                      _buildDetailSection(
                          _languageService.translate(
                              'ingredientDetails.description', 'Description'),
                          details['description']),
                      const SizedBox(height: 24),
                    ],
                    if (details['health_effects'] != null) ...[
                      _buildDetailSection(
                          _languageService.translate(
                              'ingredientDetails.healthEffects',
                              'Health Effects'),
                          details['health_effects']),
                      const SizedBox(height: 24),
                    ],
                    if (details['why_avoid'] != null) ...[
                      _buildDetailSection(
                          _languageService.translate(
                              'ingredientDetails.whyAvoid', 'Why Avoid'),
                          details['why_avoid']),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),

            // Close Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ),
      ],
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
            child: CustomScrollView(
              slivers: [
                // Header with BACK BUTTON - CRITICAL FIX
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: isTablet ? 200 : 160,
                  floating: false,
                  pinned: true,
                  // CRITICAL: Show back button for unsigned users
                  leading: IconButton(
                    icon: Icon(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? Icons.arrow_back_ios
                          : Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
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
                                  width: isTablet ? 40 : 32,
                                  height: isTablet ? 40 : 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
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
                                Icon(
                                  Icons.scanner,
                                  color: Colors.white,
                                  size: isTablet ? 28 : 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate(
                                  'scanner.title', 'Try Our Scanner'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _languageService.translate('scanner.trySubtitle',
                                  'Test our ingredient detection - no account needed'),
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

                // Demo Notice
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF59E0B).withOpacity(0.1),
                            const Color(0xFFD97706).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info,
                              color: const Color(0xFFF59E0B),
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _languageService.translate(
                                      'scanner.demoMode', 'Demo Mode'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _languageService.translate(
                                      'scanner.demoDescription',
                                      'Try our scanner! Sign up for full features and personal lists'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 10,
                                    color: const Color(0xFFF59E0B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Rest of the scanner interface - same as FoodPage
                // Explanations Toggle
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Container(
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
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF6366F1),
                            size: isTablet ? 24 : 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _languageService.translate(
                                  'scanner.showDetailedExplanations',
                                  'Show detailed explanations'),
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Switch(
                            value: showExplanations,
                            onChanged: (value) {
                              setState(() {
                                showExplanations = value;
                              });
                            },
                            activeColor: const Color(0xFF6366F1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Scanning Interface (same as FoodPage but simplified)
                if (textScanning) ...[
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      padding: EdgeInsets.all(isTablet ? 32 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: isTablet ? 80 : 60,
                              height: isTablet ? 80 : 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF8B5CF6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.scanner,
                                color: Colors.white,
                                size: isTablet ? 40 : 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _languageService.translate('scanner.analyzing',
                                'Analyzing ingredients...'),
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _languageService.translate('scanner.pleaseWait',
                                'Please wait while we scan your image'),
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          LinearProgressIndicator(
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (imageFile == null) ...[
                  // Welcome Interface
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      padding: EdgeInsets.all(isTablet ? 32 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: isTablet ? 120 : 100,
                            height: isTablet ? 120 : 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6366F1).withOpacity(0.1),
                                  const Color(0xFF8B5CF6).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: const Color(0xFF6366F1),
                              size: isTablet ? 60 : 50,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _languageService.translate(
                                'scanner.readyToScan', 'Ready to Scan'),
                            style: TextStyle(
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _languageService.translate('scanner.tryDescription',
                                'Take a photo of any ingredient label to see our detection in action'),
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Image Preview
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(imageFile!.path),
                          height: isTablet ? 300 : 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Camera Controls
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCameraButton(
                            icon: Icons.photo_library,
                            label: _languageService.translate(
                                'scanner.gallery', 'Gallery'),
                            onPressed: () => getImage(ImageSource.gallery),
                            isTablet: isTablet,
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCameraButton(
                            icon: Icons.camera_alt,
                            label: _languageService.translate(
                                'scanner.camera', 'Camera'),
                            onPressed: () => getImage(ImageSource.camera),
                            isTablet: isTablet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Results Section (same as FoodPage)
                if (warning) ...[
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFEF4444).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.warning,
                                  color: const Color(0xFFEF4444),
                                  size: isTablet ? 24 : 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _languageService.translate(
                                          'scanner.warning', 'Warning'),
                                      style: TextStyle(
                                        fontSize: isTablet ? 20 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFEF4444),
                                      ),
                                    ),
                                    Text(
                                      '$counter ${_languageService.translate('scanner.harmfulIngredientsFound', 'harmful ingredients detected')}',
                                      style: TextStyle(
                                        fontSize: isTablet ? 14 : 12,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: screenHeight * 0.4,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: detectedItems.entries.map((entry) {
                                  String ingredientKey = entry.key;
                                  Map<String, dynamic> details = entry.value;
                                  String displayName =
                                      details['name'] ?? ingredientKey;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFEF4444)
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: showExplanations
                                          ? () => _showIngredientDetails(
                                              ingredientKey, details)
                                          : null,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color:
                                                  details['severity'] == 'high'
                                                      ? const Color(0xFFEF4444)
                                                      : const Color(0xFFF59E0B),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              displayName,
                                              style: TextStyle(
                                                fontSize: isTablet ? 16 : 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF0F172A),
                                                decoration: showExplanations
                                                    ? TextDecoration.underline
                                                    : TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                          if (showExplanations) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.info_outline,
                                              size: isTablet ? 20 : 16,
                                              color: const Color(0xFF6366F1),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          if (showExplanations && detectedItems.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              _languageService.translate(
                                  'scanner.tapForDetails',
                                  'Tap ingredients for detailed information'),
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: const Color(0xFF64748B),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ] else if (starting && !warning) ...[
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: const Color(0xFF10B981),
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _languageService.translate(
                                      'scanner.allClear', 'All Clear!'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _languageService.translate(
                                      'scanner.noHarmfulIngredients',
                                      'No harmful ingredients detected!'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: const Color(0xFF64748B),
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

                // Call to Action for Sign Up
                if (starting) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.1),
                              const Color(0xFF8B5CF6).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _languageService.translate(
                                  'scanner.likeWhatYouSee',
                                  'Like what you see?'),
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate(
                                  'scanner.signUpForMore',
                                  'Sign up for personal lists, history, and more features'),
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: const Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 32 : 24,
                                  vertical: isTablet ? 16 : 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _languageService.translate(
                                    'scanner.getStarted', 'Get Started'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Error Message
                if (message.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: const Color(0xFFEF4444),
                            size: isTablet ? 24 : 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isTablet,
    bool isPrimary = false,
  }) {
    return Container(
      height: isTablet ? 60 : 52,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
              )
            : null,
        color: isPrimary ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(
                color: const Color(0xFF6366F1),
                width: 2,
              ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? const Color(0xFF6366F1).withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: isPrimary ? 15 : 10,
            offset: Offset(0, isPrimary ? 8 : 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : const Color(0xFF6366F1),
              size: isTablet ? 24 : 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : const Color(0xFF6366F1),
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
