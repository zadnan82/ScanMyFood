// lib/List/mylist.dart - Fixed version with proper list loading and camera
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scanmyfood/dbHelper/shared_prefs.dart';
import 'package:scanmyfood/services/language_service.dart';

class MyList extends StatefulWidget {
  const MyList({Key? key}) : super(key: key);

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  Future<void> _loadCustomList() async {
    setState(() => isLoading = true);
    try {
      final savedList = await SharedPrefs().getCustomIngredientsList();
      setState(() {
        customIngredients = savedList;
        isLoading = false;
      });
      debugPrint('🔍 Loaded custom ingredients: $customIngredients');
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('❌ Error loading custom list: $e');
    }
  }

  String _fixCommonOCRMistakes(String text) {
    String fixed = text.toLowerCase();

    // Add language-specific character fixes
    final languageService = context.read<LanguageService>();
    switch (languageService.currentLanguageCode) {
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
    setState(() {
      detectedIngredients = [];
      warning = false;
      message = "";
      textScanning = true;
      hasScanned = false;
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

      String fixedText = _fixCommonOCRMistakes(totalText);
      String cleanedText = fixedText.replaceAll(RegExp(r'[^\w\s]'), ' ');

      debugPrint('🔍 Scanned text: $cleanedText');
      debugPrint('🔍 Checking against custom ingredients: $customIngredients');

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
            debugPrint('⚠️ Found harmful ingredient: $customIngredient');
          }
        }
      }

      hasScanned = true;
      debugPrint(
          '✅ Scan complete. Found ${detectedIngredients.length} harmful ingredients');
    } catch (e) {
      final languageService = context.read<LanguageService>();
      message = languageService.translate(
          "errors.scanningError", "Error occurred while scanning");
      debugPrint('❌ Scanning error: $e');
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
          imageFile = pickedImage;
        });
        await getRecognisedText(pickedImage);
      }
    } catch (e) {
      final languageService = context.read<LanguageService>();
      setState(() {
        imageFile = null;
        message = languageService.translate(
            "errors.imagePickerError", "Error occurred while selecting image");
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
              // Clean Header - FIXED: Better spacing to prevent overflow
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
                                    'myList.title', 'My Personal List'),
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
                                languageService.translate('myList.subtitle',
                                    'Scan with your custom ingredient list'),
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
                    const SizedBox(width: 8),
                    // Personal List Info
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark,
                            color: const Color(0xFF10B981),
                            size: isTablet ? 14 : 12,
                          ),
                          const SizedBox(width: 4),
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                '${customIngredients.length} ${languageService.translate('myList.ingredients', 'items')}',
                                style: TextStyle(
                                  fontSize: isTablet ? 11 : 10,
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
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
                      // Show loading state
                      if (isLoading) ...[
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ]
                      // Show empty state if no custom ingredients
                      else if (customIngredients.isEmpty) ...[
                        _buildEmptyState(isTablet),
                      ]
                      // Show custom ingredients list
                      else ...[
                        _buildCustomIngredientsList(isTablet),

                        const SizedBox(height: 24),

                        // Scanning Interface
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

                        // Results
                        if (hasScanned) ...[
                          if (warning) ...[
                            _buildWarningResults(isTablet),
                          ] else ...[
                            _buildAllClearResults(isTablet),
                          ],
                        ],

                        // Error Message
                        if (message.isNotEmpty) ...[
                          _buildErrorMessage(isTablet),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Add refresh button
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCustomList,
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
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
                  Icons.list_alt,
                  color: const Color(0xFF2563EB),
                  size: isTablet ? 40 : 35,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                languageService.translate(
                    'myList.noCustomList', 'No custom list created yet'),
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                languageService.translate('myList.goToCreateList',
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
        );
      },
    );
  }

  Widget _buildCustomIngredientsList(bool isTablet) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bookmark,
                    color: const Color(0xFF10B981),
                    size: isTablet ? 20 : 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    languageService.translate(
                        'myList.yourCustomList', 'Your Custom List'),
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${customIngredients.length} ${languageService.translate('myList.ingredients', 'items')}',
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: customIngredients.map((ingredient) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : 10,
                      vertical: isTablet ? 6 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      ingredient.toUpperCase(),
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
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
                languageService.translate('myList.scanningForIngredients',
                    'Scanning for your ingredients...'),
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                languageService.translate('myList.checkingAgainstList',
                    'Checking against your personal list'),
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
                    'scanner.readyToScan', 'Ready to Scan'),
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                languageService.translate('myList.usePersonalBlacklist',
                    'Use your personal blacklist to scan ingredient labels!'),
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

  Widget _buildWarningResults(bool isTablet) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageService.translate('myList.alert', 'Alert!'),
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        Text(
                          '${detectedIngredients.length} ${languageService.translate('myList.ingredientsFromListDetected', 'ingredients from your list detected')}',
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
              Text(
                languageService.translate(
                    'myList.itemsFromListFound', 'Items from your list found:'),
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ...detectedIngredients.map((ingredient) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.2)),
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
                          ingredient.toUpperCase(),
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllClearResults(bool isTablet) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageService.translate(
                          'scanner.allClear', 'All Clear!'),
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      languageService.translate('myList.noItemsDetected',
                          'No items from your list detected!'),
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
        );
      },
    );
  }

  Widget _buildErrorMessage(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
