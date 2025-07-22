import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanmyfood/dbHelper/shared_prefs.dart';

class MyList extends StatefulWidget {
  const MyList({super.key});

  @override
  MyListState createState() => MyListState();
}

class MyListState extends State<MyList> {
  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  XFile? imageFile;
  int counter = 0;
  bool textScanning = false;
  bool warning = false;

  String resultEn = "Nothing has been found!";
  String resultSe = "Inget har hittats!";
  String resultES = "¡No se ha encontrado nada!";
  String result = "";
  bool starting = false;
  String message = "";
  List<String> words = [];
  String dangerousItemsDetected = "";
  String textEn =
      "Here you can use your own list that you have created and saved on your device! If you haven't done that yet then click on the pen in the bottom of the page and start creating your own list of unwanted additives!";
  String textSe =
      "Här kan du använda din egen lista som du har skapat och sparat på din enhet! Om du inte har gjort det än tryck på pennan längst ner på sidan och börja skapa din egen lista av oönskade tillsatser!";
  String textEs =
      "¡Aquí puede usar su propia lista que ha creado y guardado en su dispositivo! Si aún no lo ha hecho, haga clic en el bolígrafo en la parte inferior de la página y comience a crear su propia lista de aditivos no deseados";

  String warning1 = "";
  String warning2 = "";
  String yourList = "";
  String textExplain = "";

  void _loadSelectedLanguage() async {
    String warning1En = "Items found: ";
    String warning1Se = "Hittade ämnen:";
    String warning1Es = "Artículos encontrados: ";
    String yourListEn = "Your List";
    String yourListSe = "Din Lista";
    String yourListEs = "Tu Lista";
    if (SharedPrefs().mylanguage == 'English') {
      warning1 = warning1En;
      yourList = yourListEn;
      textExplain = textEn;
      result = resultEn;
    } else if (SharedPrefs().mylanguage == 'Swedish') {
      warning1 = warning1Se;
      yourList = yourListSe;
      textExplain = textSe;
      result = resultSe;
    } else if (SharedPrefs().mylanguage == 'Spanish') {
      warning1 = warning1Es;
      yourList = yourListEs;
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
    warning = false;
    var totalText = "";
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = TextRecognizer();
    final RecognizedText recognisedText =
        await textDetector.processImage(inputImage);
    await textDetector.close();

    RegExp splitter = RegExp(r'[,\.\;\-/[\](){}<>!@#$%^&*+=|\~`/?\d]');

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
      if (SharedPrefs().mylist.contains(processedWord)) {
        warning = true;
        counter++;
        dangerousItemsDetected =
            dangerousItemsDetected + " * " + processedWord + "\n";
        //  "  $dangerousItemsDetected$processedWord\n";
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
      message = "Error occured while scanning";
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
    final iconSize = screenSize.width * 0.12 * textScaleFactor;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20.0 * textScaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    border: Border.all(
                      color: Colors.black38,
                      width: 3.0 * textScaleFactor,
                    ),
                    borderRadius: BorderRadius.circular(50.0 * textScaleFactor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.57),
                        blurRadius: 5.0 * textScaleFactor,
                      ),
                    ],
                  ),
                  child: PhysicalModel(
                    elevation: 8.0 * textScaleFactor,
                    borderRadius: BorderRadius.circular(20.0 * textScaleFactor),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 30.0 * textScaleFactor,
                        right: 30.0 * textScaleFactor,
                      ),
                      child: DropdownButton<String>(
                        hint: Text(
                          yourList,
                          style: TextStyle(fontSize: 24.0 * textScaleFactor),
                        ),
                        onChanged: (String? value) {
                          setState(() {});
                        },
                        items:
                            SharedPrefs().mylist.map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 50.0 * textScaleFactor,
                                  right: 45.0 * textScaleFactor,
                                ),
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
                          },
                        ).toList(),
                        isExpanded: true,
                        underline: Container(),
                        icon: Padding(
                          padding: EdgeInsets.only(
                            left: 20.0 * textScaleFactor,
                            right: 20.0 * textScaleFactor,
                          ),
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: 30.0 * textScaleFactor,
                          ),
                        ),
                        iconEnabledColor: Colors.black,
                        iconSize: 30.0 * textScaleFactor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0 * textScaleFactor),
                if (textScanning) CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  Text(
                    textExplain,
                    style: TextStyle(fontSize: 20.0 * textScaleFactor),
                  ),
                if (imageFile != null)
                  Image.file(
                    File(imageFile!.path),
                    height: 200.0 * textScaleFactor,
                    fit: BoxFit.fill,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 5.0 * textScaleFactor),
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
                      margin: EdgeInsets.symmetric(
                          horizontal: 5.0 * textScaleFactor),
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
                    SizedBox(height: 20.0 * textScaleFactor),
                    if (warning)
                      Text(
                        "$warning1 ",
                        style: TextStyle(fontSize: 20.0 * textScaleFactor),
                      )
                    else
                      const Text(""),
                    SizedBox(height: 20.0 * textScaleFactor),
                    Text(
                      dangerousItemsDetected,
                      style: TextStyle(fontSize: 20.0 * textScaleFactor),
                    ),
                    SizedBox(height: 20.0 * textScaleFactor),
                    if (starting && !warning)
                      Text(
                        result,
                        style: TextStyle(fontSize: 20.0 * textScaleFactor),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
