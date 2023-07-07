import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
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
  String message = "";
  List<String> words = [];
  List<String> foodList = [];
  String dangerousItemsDetected = "";
  String textEn =
      "Here you will use our standard list of harmful food additives! Click on the camera icon to take a picture of the ingredients text of the product or on the gallery icon to access your device album if you already have a picture taken of the ingredients. To create your own list click on the pen in the bottom and then the little man icon down there to use your own list of unwanted additives!";
  String textSe =
      "Här kommer du att använda vår standardlista över skadliga livsmedelstillsatser! Tryck på kameraikonen för att ta en bild av ingredienstexten för produkten eller på galleriikonen för att komma åt ditt enhetsalbum om du redan har en bild tagen av ingredienserna. För att skapa din egen lista tryck på pennan i botten och sedan på lilla man-ikonen där nere för att använda din egen lista av oönskade tillsatser!";
  String textEs =
      "¡Aquí usará nuestra lista estándar de aditivos alimentarios nocivos! Haga clic en el ícono de la cámara para tomar una fotografía del texto de los ingredientes del producto o en el ícono de la galería para acceder al álbum de su dispositivo si ya tomó una fotografía de los ingredientes. ¡Para crear su propia lista, haga clic en el bolígrafo en la parte inferior y luego en el icono del hombrecito que está abajo para usar su propia lista de aditivos no deseados!";
  String warning1 = "";
  String warning2 = "";
  String ourList = "";
  String textExplain = "";

  void _loadSelectedLanguage() async {
    String warning1En = "Items found: ";
    String warning1Se = "Hittade ämnen:";
    String warning1Es = "Artículos encontrados: ";
    String ourListEn = "Our List";
    String ourListSe = "Vår Lista";
    String ourListEs = "Nuestra Lista";

    if (SharedPrefs().mylanguage == 'English') {
      foodList = SharedPrefs().foodEn;
      warning1 = warning1En;
      ourList = ourListEn;
      textExplain = textEn;
      result = resultEn;
    } else if (SharedPrefs().mylanguage == 'Swedish') {
      foodList = SharedPrefs().foodSe;
      warning1 = warning1Se;
      ourList = ourListSe;
      textExplain = textSe;
      result = resultSe;
    } else if (SharedPrefs().mylanguage == 'Spanish') {
      foodList = SharedPrefs().foodEs;
      warning1 = warning1Es;
      ourList = ourListEs;
      textExplain = textEs;
      result = resultES;
    }
  }

  void getRecognisedText(XFile image) async {
    words = [];
    dangerousItemsDetected = "";
    counter = 0;
    textScanning = false;
    message = "";
    var totalText = "";
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    RegExp splitter = RegExp(r'[:,\.\;\-/[\](){}<>!@#$%^&*+=|\~`/?\d]');

    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        String lineText = line.text;

        totalText = totalText + " " + lineText;
      }
    }
    words = totalText.split(splitter);

    for (String word in words) {
      String processedWord = word.toLowerCase().trim();

      processedWord = processedWord.replaceAll(RegExp(r'\(\d+\%?\)'), '');
      starting = true;
      if (foodList.contains(processedWord)) {
        warning = true;
        counter++;
        dangerousItemsDetected =
            dangerousItemsDetected + " * " + processedWord + "\n";
      }
    }
    totalText = "";

    textScanning = false;
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width; 
  final textScaleFactor = screenWidth > 600
        ? 1.4
        : screenWidth < 500
            ? 0.8
            : 1.2;
    final imageHeight = screenWidth * 0.35
    
     * textScaleFactor;
    final iconSize = screenSize.width * 0.12 * textScaleFactor;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 100.0, left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  border: Border.all(
                    color: Colors.black38,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.57),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: PhysicalModel(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.black,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: DropdownButton<String>(
                      hint: Text(
                        ourList,
                        style: TextStyle(fontSize: 20.0 * textScaleFactor),
                      ),
                      onChanged: (String? value) {
                        setState(() {});
                      },
                      items: foodList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: EdgeInsets.only(left: 50, right: 45),
                            child: Text(
                              value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.0 * textScaleFactor,
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 41, 41, 41),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      underline: Container(),
                      icon: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Icon(
                          Icons.arrow_drop_down,
                          size: 30.0 * textScaleFactor,
                        ),
                      ),
                      iconEnabledColor: Colors.black,
                      iconSize: 20.0 * textScaleFactor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (textScanning) CircularProgressIndicator(),
              if (!textScanning && imageFile == null)
                Text(
                  textExplain,
                  style: TextStyle(
                    fontSize: 20.0 * textScaleFactor,
                  ),
                ),
              if (imageFile != null)
                Image.file(
                  File(imageFile!.path),
                  height: imageHeight,
                  fit: BoxFit.fill,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 5.0 * textScaleFactor),
                    padding: EdgeInsets.only(top: 10.0 * textScaleFactor),
                    child: IconButton(
                      icon: Image.asset('assets/images/gallery.png'),
                      iconSize: iconSize,
                      onPressed: () {
                        getImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 5.0 * textScaleFactor),
                    padding: EdgeInsets.only(top: 10.0 * textScaleFactor),
                    child: IconButton(
                      icon: Image.asset('assets/images/camera.png'),
                      iconSize: iconSize,
                      onPressed: () {
                        getImage(ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 20 * textScaleFactor,
                  ),
                  if (warning)
                    Text(
                      "$warning1 ",
                      style: TextStyle(
                        fontSize: 20.0 * textScaleFactor,
                      ),
                    )
                  else
                    const Text(""),
                  SizedBox(
                    height: 20 * textScaleFactor,
                  ),
                  Text(
                    dangerousItemsDetected,
                    style: TextStyle(
                      fontSize: 20.0 * textScaleFactor,
                    ),
                  ),
                  SizedBox(
                    height: 20 * textScaleFactor,
                  ),
                  if (starting && !warning)
                    Text(
                      result,
                      style: TextStyle(
                        fontSize: 20.0 * textScaleFactor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
