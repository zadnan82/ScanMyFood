// lib/List/mylist.dart - Updated version
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanmyfood/dbHelper/shared_prefs.dart';
import 'package:scanmyfood/services/language_service.dart';

class MyList extends StatefulWidget {
  const MyList({Key? key}) : super(key: key);

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final LanguageService _languageService = LanguageService.instance;

  XFile? imageFile;
  bool textScanning = false;
  bool warning = false;
  bool hasScanned = false;
  String message = "";
  List<String> customIngredients = [];
  List<String> detectedIngredients = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCustomList();
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

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomList() async {
    setState(() => isLoading = true);
    try {
      final savedList = await SharedPrefs().getCustomIngredientsList();
      setState(() {
        customIngredients = savedList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading custom list: $e');
    }
  }

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
        .replaceAll('ù', 'u');

    return fixed;
  }

  Future<void> getRecognisedText(XFile image) async {
    detectedIngredients = [];
    warning = false;
    message = "";
    String totalText = "";

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textDetector = TextRecognizer();
      final RecognizedText recognisedText =
          await textDetector.processImage(inputImage);
      await textDetector.close();

      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          totalText = "$totalText ${line.text}";
        }
      }

      String fixedText = _fixCommonOCRMistakes(totalText);
      String cleanedText = fixedText.replaceAll(RegExp(r'[^\w\s]'), ' ');

      // Check against custom ingredients list
      for (String customIngredient in customIngredients) {
        String lowerCustom = customIngredient.toLowerCase();

        if (cleanedText.contains(lowerCustom)) {
          bool found = false;

          if (!lowerCustom.contains(' ') && !lowerCustom.contains('-')) {
            List<String> cleanWords = cleanedText.split(RegExp(r'\s+'));
            for (String word in cleanWords) {
              String cleanWord = word.toLowerCase().trim();
              cleanWord = cleanWord.replaceAll(RegExp(r'[^\w]'), '');
              if (cleanWord == lowerCustom) {
                found = true;
                break;
              }
            }
          } else {
            found = true;
          }

          if (found && !detectedIngredients.contains(customIngredient)) {
            warning = true;
            detectedIngredients.add(customIngredient);
          }
        }
      }

      hasScanned = true;
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

  Future<void> getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          textScanning = true;
          imageFile = pickedImage;
        });
        await getRecognisedText(pickedImage);
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
                // Header
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: isTablet ? 200 : 160,
                  floating: false,
                  pinned: true,
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
                                  Icons.list_alt,
                                  color: Colors.white,
                                  size: isTablet ? 28 : 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate(
                                  'myList.title', 'My Personal List'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _languageService.translate('myList.subtitle',
                                  'Scan with your custom ingredient list'),
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

                // Personal List Info
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
                              Icons.bookmark,
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
                                  _languageService.translate(
                                      'myList.personalList',
                                      'Your Personal List'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${customIngredients.length} ${_languageService.translate('myList.ingredients', 'ingredients')}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: const Color(0xFF10B981),
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

                // Main Content
                if (customIngredients.isEmpty) ...[
                  // Empty State
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 40 : 32),
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
                          children: [
                            Container(
                              width: isTablet ? 100 : 80,
                              height: isTablet ? 100 : 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.list_alt,
                                color: const Color(0xFF94A3B8),
                                size: isTablet ? 50 : 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _languageService.translate('myList.noCustomList',
                                  'No custom list created yet'),
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _languageService.translate(
                                  'myList.goToCreateList',
                                  'Go to "Create List" to build your personal ingredient blacklist'),
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
                  ),
                ] else ...[
                  // Scanning Interface
                  if (textScanning) ...[
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 16),
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
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
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
                              _languageService.translate(
                                  'myList.scanningForIngredients',
                                  'Scanning for your ingredients...'),
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate(
                                  'myList.checkingAgainstList',
                                  'Checking against your personal list'),
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const LinearProgressIndicator(
                              backgroundColor: Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (imageFile == null) ...[
                    // Welcome State
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 16),
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
                              _languageService.translate(
                                  'myList.usePersonalBlacklist',
                                  'Use your personal blacklist to scan ingredient labels! If you haven\'t created one yet, go to the \'Create List\' tab.'),
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
                        margin: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 16),
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
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Results Section
                  if (hasScanned) ...[
                    if (warning) ...[
                      SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 16),
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
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.1),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _languageService.translate(
                                              'myList.alert', 'Alert!'),
                                          style: TextStyle(
                                            fontSize: isTablet ? 20 : 18,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFEF4444),
                                          ),
                                        ),
                                        Text(
                                          '${detectedIngredients.length} ${_languageService.translate('myList.ingredientsFromListDetected', 'ingredients from your list detected')}',
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
                              Text(
                                _languageService.translate(
                                    'myList.itemsFromListFound',
                                    'Items from your list found:'),
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight: screenHeight * 0.3,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children:
                                        detectedIngredients.map((ingredient) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFEF4444)
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFEF4444),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                ingredient,
                                                style: TextStyle(
                                                  fontSize: isTablet ? 14 : 12,
                                                  color:
                                                      const Color(0xFF0F172A),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 16),
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
                                  color:
                                      const Color(0xFF10B981).withOpacity(0.1),
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
                                          'myList.noItemsDetected',
                                          'No items from your list detected!'),
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
                  ],
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
            ? const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
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
