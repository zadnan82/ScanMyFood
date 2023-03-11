import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanmyfood/shared_prefs.dart'; 

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
  String message = "";
  List<String> words = [];
  String dangerousItemsDetected = "";
  String textEn =
      "Here you can use you own list that you have created and saved on your device! if you haen't yet then click on the pen in the bottom of the page and start creating you own list of unwanted items!";
  String textSe =
      "Här kan du använda din egen lista som du har skapat och sparat på din enhet! om du inte har gjort det ännu, klicka på pennan längst ner på sidan och börja skapa din egen lista över oönskade föremål!";
  String textEs =
      "¡Aquí puede usar su propia lista que ha creado y guardado en su dispositivo! Si aún no lo ha hecho, haga clic en el bolígrafo en la parte inferior de la página y comience a crear su propia lista de elementos no deseados";
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
    } else if (SharedPrefs().mylanguage == 'Swedish') {
      warning1 = warning1Se;
      yourList = yourListSe;
       textExplain = textSe;
    } else if (SharedPrefs().mylanguage == 'Spanish') {
      warning1 = warning1Es;
      yourList = yourListEs;
       textExplain = textEs;
    }
  }

  void getRecognisedText(XFile image) async { 
    words = [];
    dangerousItemsDetected = "";
    counter = 0;
    textScanning = false;
    message = "";
    warning = false;
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        String lineText = line.text;
        List<String> words = lineText.split(',');
        for (String word in words) {
          String processedWord = word.toLowerCase().trim();
          processedWord = processedWord.replaceAll(RegExp(r'\(\d+\%?\)'), '');

          if (SharedPrefs().mylist.contains(processedWord)) {
            warning = true;
            counter++;
            dangerousItemsDetected =
                // " * " + dangerousItemsDetected + processedWord + "\n";
                 " * $dangerousItemsDetected$processedWord\n";
          }
        }
      }
    }
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
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      border: Border.all(color: Colors.black38, width: 3),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)
                      ]),
                  child: PhysicalModel(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    shadowColor: Colors.black,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: DropdownButton<String>(
                        hint: Text(yourList),
                        onChanged: (String? value) {
                          setState(() {});
                        },
                        items: SharedPrefs().mylist
                            .map<DropdownMenuItem<String>>((String value) {
                          
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 45),
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromARGB(255, 41, 41, 41),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        isExpanded: true,
                        underline: Container(),
                        icon: const Padding(
                            //Icon at tail, arrow bottom is default icon
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Icon(Icons.arrow_drop_down)),
                        iconEnabledColor: Colors.black, //Icon color
                        iconSize: 30,
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 20)),
                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                          Text(textExplain),
                if (imageFile != null)
                  Image.file(File(imageFile!.path),
                      height: 200, fit: BoxFit.fill),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.only(top: 10),
                      child: IconButton(
                        icon: Image.asset('assets/images/gallery.png'),
                        iconSize: 50,
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.only(top: 10),
                      child: IconButton(
                        icon: Image.asset('assets/images/camera.png'),
                        iconSize: 50,
                        onPressed: () {
                          getImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    warning
                        ? Text(
                            "$warning1 ",
                            style: const TextStyle(fontSize: 20),
                          )
                        : const Text(""),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      dangerousItemsDetected,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )
              ],
            )),
      )),
    );
  }
}
