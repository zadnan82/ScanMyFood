// lib/food.dart - Simplified clean scanner page
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  // Scanning variables
  XFile? imageFile;
  int counter = 0;
  bool textScanning = false;
  bool warning = false;
  bool showExplanations = false;
  String message = "";
  Map<String, Map<String, dynamic>> detectedItems = {};
  bool starting = false;

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
        .replaceAll('ù', 'u')
        .replaceAll('arficialflavor', 'artificial flavor')
        .replaceAll('artifical', 'artificial');

    return fixed;
  }

  void getRecognisedText(XFile image) async {
    setState(() {
      detectedItems = {};
      counter = 0;
      textScanning = true;
      message = "";
      warning = false;
      starting = false;
    });

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textDetector = TextRecognizer();
      RecognizedText recognisedText =
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

      // Use language service to get current ingredients
      final languageService = context.read<LanguageService>();
      final currentIngredients = languageService.ingredients;
      final harmfulIngredients = languageService.harmfulIngredientKeys;

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
        }
      }

      starting = true;
    } catch (e) {
      final languageService = context.read<LanguageService>();
      message = languageService.translate(
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
          imageFile = pickedImage;
        });
        getRecognisedText(pickedImage);
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

  void _showIngredientDetails(
      String ingredientKey, Map<String, dynamic> details) {
    final languageService = context.read<LanguageService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
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
                      size: 20,
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
                            fontSize: 18,
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
                            languageService.translate(
                                'ingredientDetails.${details['severity'] ?? 'medium'}Risk',
                                '${details['severity'] ?? 'MEDIUM'} RISK'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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
                          languageService.translate(
                              'ingredientDetails.description', 'Description'),
                          details['description']),
                      const SizedBox(height: 20),
                    ],
                    if (details['health_effects'] != null) ...[
                      _buildDetailSection(
                          languageService.translate(
                              'ingredientDetails.healthEffects',
                              'Health Effects'),
                          details['health_effects']),
                      const SizedBox(height: 20),
                    ],
                    if (details['why_avoid'] != null) ...[
                      _buildDetailSection(
                          languageService.translate(
                              'ingredientDetails.whyAvoid', 'Why Avoid'),
                          details['why_avoid']),
                      const SizedBox(height: 20),
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
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      Text(languageService.translate('common.close', 'Close')),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
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
                                    'scanner.title', 'Ingredient Scanner'),
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
                                languageService.translate('scanner.subtitle',
                                    'Detect harmful additives instantly'),
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
                    // Show detailed explanations toggle
                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Switch(
                          value: showExplanations,
                          onChanged: (value) {
                            setState(() {
                              showExplanations = value;
                            });
                          },
                          activeColor: const Color(0xFF2563EB),
                        );
                      },
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
                      if (warning) ...[
                        _buildWarningResults(isTablet),
                      ] else if (starting && !warning) ...[
                        _buildAllClearResults(isTablet),
                      ],

                      // Error Message
                      if (message.isNotEmpty) ...[
                        _buildErrorMessage(isTablet),
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
                    'scanner.analyzing', 'Analyzing ingredients...'),
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                languageService.translate('scanner.pleaseWait',
                    'Please wait while we scan your image'),
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
                languageService.translate('scanner.scanDescription',
                    'Take a photo of any ingredient label to instantly detect harmful additives'),
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
                          languageService.translate(
                              'scanner.warning', 'Warning'),
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        Text(
                          '$counter ${languageService.translate('scanner.harmfulIngredientsFound', 'harmful ingredients detected')}',
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
              ...detectedItems.entries.map((entry) {
                String ingredientKey = entry.key;
                Map<String, dynamic> details = entry.value;
                String displayName = details['name'] ?? ingredientKey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.2)),
                  ),
                  child: InkWell(
                    onTap: showExplanations
                        ? () => _showIngredientDetails(ingredientKey, details)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: details['severity'] == 'high'
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
                              fontSize: isTablet ? 14 : 13,
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
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFF2563EB),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
              if (showExplanations && detectedItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  languageService.translate('scanner.tapForDetails',
                      'Tap ingredients for detailed information'),
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    color: const Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
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
                      languageService.translate('scanner.noHarmfulIngredients',
                          'No harmful ingredients detected!'),
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
