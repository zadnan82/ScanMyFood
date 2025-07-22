import 'dart:io';
import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanmyfood/dbHelper/shared_prefs.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
    _loadIngredientsFromJSON();
  }

  String resultEn = "Nothing has been found!";
  String resultSe = "Inget har hittats!";
  String resultES = "¡No se ha encontrado nada!";
  String result = "";
  bool starting = false;

  XFile? imageFile;
  int counter = 0;
  bool textScanning = false;
  bool warning = false;
  bool showExplanations = false; // New toggle for explanations
  String message = "";
  List<String> words = [];
  Map<String, dynamic> ingredientsData = {}; // Store JSON data
  List<String> harmfulIngredients = []; // List of harmful ingredient keys
  String dangerousItemsDetected = "";
  Map<String, Map<String, dynamic>> detectedItems =
      {}; // Store detected items with details

  String textEn =
      "Here you will use our comprehensive database of harmful food additives! Click on the camera icon to take a picture of the ingredients text of the product or on the gallery icon to access your device album if you already have a picture taken of the ingredients. Toggle explanations to see why ingredients are harmful!";
  String textSe =
      "Här kommer du att använda vår omfattande databas över skadliga livsmedelstillsatser! Tryck på kameraikonen för att ta en bild av ingredienstexten för produkten eller på galleriikonen för att komma åt ditt enhetsalbum om du redan har en bild tagen av ingredienserna. Växla förklaringar för att se varför ingredienser är skadliga!";
  String textEs =
      "¡Aquí usará nuestra base de datos integral de aditivos alimentarios nocivos! Haga clic en el ícono de la cámara para tomar una fotografía del texto de los ingredientes del producto o en el ícono de la galería para acceder al álbum de su dispositivo si ya tomó una fotografía de los ingredientes. ¡Active las explicaciones para ver por qué los ingredientes son dañinos!";
  String warning1 = "";
  String warning2 = "";
  String ourList = "";
  String textExplain = "";

  // Load ingredients from JSON file
  Future<void> _loadIngredientsFromJSON() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/ingredients.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);

      setState(() {
        ingredientsData = jsonData['ingredients'];
        harmfulIngredients = ingredientsData.keys.toList();
      });
    } catch (e) {
      print('Error loading ingredients JSON: $e');
      // Fallback to empty data if JSON fails to load
      setState(() {
        ingredientsData = {};
        harmfulIngredients = [];
      });
    }
  }

  void _loadSelectedLanguage() async {
    String warning1En = "Items found: ";
    String warning1Se = "Hittade ämnen: ";
    String warning1Es = "Artículos encontrados: ";
    String ourListEn = "Harmful Ingredients Database";
    String ourListSe = "Databas för Skadliga Ingredienser";
    String ourListEs = "Base de Datos de Ingredientes Nocivos";

    if (SharedPrefs().mylanguage == 'English') {
      warning1 = warning1En;
      ourList = ourListEn;
      textExplain = textEn;
      result = resultEn;
    } else if (SharedPrefs().mylanguage == 'Swedish') {
      warning1 = warning1Se;
      ourList = ourListSe;
      textExplain = textSe;
      result = resultSe;
    } else if (SharedPrefs().mylanguage == 'Spanish') {
      warning1 = warning1Es;
      ourList = ourListEs;
      textExplain = textEs;
      result = resultES;
    }
  }

  // Simple text preprocessing to fix common OCR mistakes
  String _fixCommonOCRMistakes(String text) {
    String fixed = text.toLowerCase();

    // Fix special characters from OCR issues
    fixed = fixed
        .replaceAll('š', 's')
        .replaceAll('ó', 'o')
        .replaceAll('à', 'a')
        .replaceAll('è', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('ù', 'u');

    // Fix common word mistakes
    fixed = fixed
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

      // Apply OCR fixes
      String fixedText = _fixCommonOCRMistakes(totalText);
      String cleanedText = fixedText.replaceAll(RegExp(r'[^\w\s]'), ' ');

      // Debug: Print what we actually found in the text
      print("=== DEBUG INFO ===");
      print("OCR Text: $totalText");
      print("Cleaned Text: $cleanedText");
      print(
          "Available ingredients in JSON: ${harmfulIngredients.take(10).toList()}...");

      // Check for harmful ingredients from JSON with enhanced matching
      for (String ingredientKey in harmfulIngredients) {
        String ingredientName =
            ingredientsData[ingredientKey]['name'] ?? ingredientKey;

        bool found = false;
        String lowerKey = ingredientKey.toLowerCase();

        // ENHANCED MATCHING: Support partial phrase matching for complex ingredients
        if (cleanedText.contains(lowerKey)) {
          // Direct exact match found
          if (!lowerKey.contains(' ') && !lowerKey.contains('-')) {
            // For single words, ensure it's a complete word match
            List<String> cleanWords = cleanedText.split(RegExp(r'\s+'));
            bool exactWordMatch = false;

            for (String word in cleanWords) {
              String cleanWord = word.toLowerCase().trim();
              cleanWord = cleanWord.replaceAll(RegExp(r'[^\w]'), '');

              if (cleanWord == lowerKey) {
                // Special check for "red" to avoid "reduced" false positive
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
            // For multi-word ingredients, the contains check is sufficient
            found = true;
          }
        } else {
          // ENHANCED: Check for flexible phrase matching
          // Split the ingredient key into words and check if all significant words are present
          List<String> keyWords = lowerKey.split(RegExp(r'[\s\-_]+'));
          if (keyWords.length > 1) {
            // METHOD 1: Check if the exact phrase exists (most reliable)
            bool exactPhraseFound = cleanedText.contains(lowerKey);

            if (!exactPhraseFound) {
              // METHOD 2: Check if words appear in close proximity (within reasonable distance)
              bool proximityMatch = false;
              List<String> textWords = cleanedText.split(RegExp(r'\s+'));

              for (int i = 0; i < textWords.length - keyWords.length + 1; i++) {
                bool allWordsInProximity = true;

                // Check if all key words appear within a small window (e.g., 5 words)
                for (int j = 0; j < keyWords.length; j++) {
                  String keyWord = keyWords[j];
                  if (keyWord.length > 2) {
                    bool foundInWindow = false;

                    // Look for this key word within a window of 5 words from current position
                    for (int k = i;
                        k < Math.min(i + 5, textWords.length);
                        k++) {
                      if (textWords[k].toLowerCase().contains(keyWord)) {
                        foundInWindow = true;
                        break;
                      }
                    }

                    if (!foundInWindow) {
                      allWordsInProximity = false;
                      break;
                    }
                  }
                }

                if (allWordsInProximity) {
                  proximityMatch = true;
                  break;
                }
              }

              // Only consider it a match if words are in proximity
              if (proximityMatch) {
                bool containsRed = keyWords.any((word) => word == "red");

                if (containsRed && cleanedText.contains("reduced")) {
                  found =
                      false; // Block red colorings when "reduced" is present
                } else {
                  found = true;
                }
              }
            } else {
              // Exact phrase found - this is reliable
              bool containsRed = keyWords.any((word) => word == "red");

              if (containsRed && cleanedText.contains("reduced")) {
                found = false; // Block red colorings when "reduced" is present
              } else {
                found = true;
              }
            }
          }

          // ENHANCEMENT 1: Special handling for "enriched flour" variants
          if (lowerKey == "enriched flour") {
            if (cleanedText.contains("enriched") &&
                cleanedText.contains("flour")) {
              found = true;
            }
          }

          // ENHANCEMENT 2: Special handling for oil variations
          if (lowerKey == "canola oil") {
            if ((cleanedText.contains("canola") &&
                    cleanedText.contains("oil")) ||
                cleanedText.contains("canola oil")) {
              found = true;
            }
          }

          if (lowerKey == "soybean oil") {
            if ((cleanedText.contains("soybean") &&
                    cleanedText.contains("oil")) ||
                cleanedText.contains("soybean oil")) {
              found = true;
            }
          }

          // ENHANCEMENT 3: Handle common ingredient variations
          if (lowerKey == "corn oil" &&
              cleanedText.contains("corn") &&
              cleanedText.contains("oil")) {
            found = true;
          }

          if (lowerKey == "palm oil" &&
              cleanedText.contains("palm") &&
              cleanedText.contains("oil")) {
            found = true;
          }

          if (lowerKey == "cottonseed oil" &&
              cleanedText.contains("cottonseed") &&
              cleanedText.contains("oil")) {
            found = true;
          }

          if (lowerKey == "safflower oil" &&
              cleanedText.contains("safflower") &&
              cleanedText.contains("oil")) {
            found = true;
          }

          if (lowerKey == "sunflower oil" &&
              cleanedText.contains("sunflower") &&
              cleanedText.contains("oil")) {
            found = true;
          }

          if (lowerKey == "vegetable oil" &&
              cleanedText.contains("vegetable") &&
              cleanedText.contains("oil")) {
            found = true;
          }

          // ADDITIONAL PROTECTION: Block red colorings when "reduced" is present
          if (lowerKey.contains("red") && cleanedText.contains("reduced")) {
            found = false;
          }
        }

        if (found) {
          print("MATCH FOUND: '$ingredientKey' -> '$ingredientName'");
        }

        if (found && !detectedItems.containsKey(ingredientKey)) {
          warning = true;
          counter++;
          detectedItems[ingredientKey] = ingredientsData[ingredientKey];
          dangerousItemsDetected += " • $ingredientName\n";
        }
      }

      print("Total matches found: $counter");
      print("===================");

      starting = true;
    } catch (e) {
      message = "Error occurred while scanning: $e";
    } finally {
      setState(() {
        textScanning = false;
      });
    }
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      message = "Error occurred while scanning";
      setState(() {});
    }
  }

  void _showCameraTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.orange),
            SizedBox(width: 8),
            Text('📸 Camera Tips'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTip('💡', 'Use good lighting - avoid shadows and glare'),
            _buildTip('📏', 'Get close to the ingredient text for clarity'),
            _buildTip('📐', 'Hold phone straight, not tilted'),
            _buildTip('🎯', 'Tap screen to focus on the text'),
            _buildTip('⏱️', 'Hold steady for 1-2 seconds when capturing'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showIngredientDetails(
      String ingredientKey, Map<String, dynamic> details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: details['severity'] == 'high' ? Colors.red : Colors.orange,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                details['name'] ?? ingredientKey,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (details['severity'] != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: details['severity'] == 'high'
                        ? Colors.red
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Severity: ${details['severity'].toString().toUpperCase()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
              ],
              if (details['description'] != null) ...[
                Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(details['description']),
                SizedBox(height: 12),
              ],
              if (details['health_effects'] != null) ...[
                Text(
                  'Health Effects:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(details['health_effects']),
                SizedBox(height: 12),
              ],
              if (details['why_avoid'] != null) ...[
                Text(
                  'Why Avoid:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(details['why_avoid']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // More responsive scaling
    final textScaleFactor = screenWidth > 600
        ? 1.2
        : screenWidth < 350
            ? 0.85
            : 1.0;

    final imageHeight = screenWidth * 0.3;
    final iconSize = screenWidth * 0.08;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: isSmallScreen ? 8.0 : 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Database Info Header - More compact
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        ourList,
                        style: TextStyle(
                          fontSize: 14.0 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${harmfulIngredients.length} ingredients',
                        style: TextStyle(
                          fontSize: 12.0 * textScaleFactor,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Toggle for explanations - More compact
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      SizedBox(width: 6),
                      Text(
                        'Show explanations',
                        style: TextStyle(fontSize: 12 * textScaleFactor),
                      ),
                      SizedBox(width: 6),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: showExplanations,
                          onChanged: (value) {
                            setState(() {
                              showExplanations = value;
                            });
                          },
                          activeColor: Colors.orange,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmallScreen ? 8 : 16),

                if (textScanning)
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "🔍 Analyzing ingredients...",
                          style: TextStyle(
                            fontSize: 12 * textScaleFactor,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!textScanning && imageFile == null)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.tips_and_updates,
                                color: Colors.blue, size: 18),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Enhanced Detection Ready!',
                                style: TextStyle(
                                  fontSize: 13 * textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          '✨ Comprehensive database & smart OCR',
                          style: TextStyle(
                            fontSize: 11 * textScaleFactor,
                            color: Colors.blue[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                if (!textScanning && imageFile == null && !isSmallScreen)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(12),
                    child: Text(
                      textExplain,
                      style: TextStyle(
                        fontSize: 13.0 * textScaleFactor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                if (imageFile != null)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(imageFile!.path),
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // Camera Buttons - More compact
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCameraButton(
                        icon: 'assets/images/gallery.png',
                        label: 'Gallery',
                        onPressed: () => getImage(ImageSource.gallery),
                        iconSize: iconSize,
                        textScaleFactor: textScaleFactor,
                      ),
                      _buildCameraButton(
                        icon: 'assets/images/camera.png',
                        label: 'Camera',
                        onPressed: () => getImage(ImageSource.camera),
                        iconSize: iconSize,
                        textScaleFactor: textScaleFactor,
                      ),
                      _buildCameraButton(
                        icon: null,
                        label: 'Tips',
                        onPressed: _showCameraTips,
                        iconSize: iconSize,
                        textScaleFactor: textScaleFactor,
                        customIcon: Icons.help_outline,
                      ),
                    ],
                  ),
                ),

                if (message.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(fontSize: 11.0 * textScaleFactor),
                    ),
                  ),

                // Results
                if (warning)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning,
                                color: Colors.red[700], size: 18),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "$warning1 ($counter items)",
                                style: TextStyle(
                                  fontSize: 14.0 * textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Display detected items in a more compact way
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.3, // Limit height
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: detectedItems.entries.map((entry) {
                                String ingredientKey = entry.key;
                                Map<String, dynamic> details = entry.value;
                                String displayName =
                                    details['name'] ?? ingredientKey;

                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 1),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: details['severity'] == 'high'
                                              ? Colors.red
                                              : Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: showExplanations
                                              ? () => _showIngredientDetails(
                                                  ingredientKey, details)
                                              : null,
                                          child: Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 13.0 * textScaleFactor,
                                              color: Colors.red[600],
                                              decoration: showExplanations
                                                  ? TextDecoration.underline
                                                  : TextDecoration.none,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      if (showExplanations)
                                        Icon(
                                          Icons.info_outline,
                                          size: 14,
                                          color: Colors.red[400],
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        if (showExplanations && detectedItems.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              'Tap ingredients for details',
                              style: TextStyle(
                                fontSize: 10 * textScaleFactor,
                                color: Colors.red[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                if (starting && !warning)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[700], size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result,
                            style: TextStyle(
                              fontSize: 14.0 * textScaleFactor,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Add some bottom padding
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraButton({
    required String? icon,
    required String label,
    required VoidCallback onPressed,
    required double iconSize,
    required double textScaleFactor,
    IconData? customIcon,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: icon != null
                  ? Image.asset(icon)
                  : Icon(customIcon,
                      size: iconSize * 0.7, color: Colors.orange),
              iconSize: iconSize,
              onPressed: onPressed,
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(
                minWidth: iconSize + 16,
                minHeight: iconSize + 16,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.0 * textScaleFactor,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
