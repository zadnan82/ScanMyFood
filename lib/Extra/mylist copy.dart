import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyList2 extends StatefulWidget {
  const MyList2({super.key});

  @override
  MyList2State createState() => MyList2State();
}

String selectList = "";
String warning1 = "";
String warning2 = "";

class MyList2State extends State<MyList2> {
  @override
  void initState() {
    super.initState();
    loadOptions();
    _loadSelectedLanguage();
  }

  XFile? imageFile;
  int counter = 0;
  bool textScanning = false;
  bool warning = false;
  String message = "";
  String? language = "";
  String chosenlist = "";
  List<String> _allLists = [];
  List<String> mylist = [];
  List<String> words = [];
  String dangerousItemsDetected = "";
  final _dropdownFormKey = GlobalKey<FormState>();
  String? selectedValue = null;

  Future<void> loadOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final all = prefs.getStringList('all') ?? [];
    setState(() {
      _allLists = all;
    });
  }

  void _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language');
    if (language != null) {
      setState(() {
      });
    }
    String warning1En = "Warning!! there are ";
    String warning2En = " harmful items in this product!";
    String warning1Se = "Varning!! det finns ";
    String warning2Se = " skadliga föremål i denna produkt!";
    String warning1Es = "¡¡Advertencia!! hay ";
    String warning2Es = " artículos dañinos en este producto!";
    String selectListEn = "Select a List";
    String selectListSe = "Välj en lista";
    String selectListEs = "Seleccione una lista";

    if (language == null || language == 'English') {
      warning1 = warning1En;
      warning2 = warning2En;
      selectList = selectListEn;
    } else if (language == 'Swedish') {
      warning1 = warning1Se;
      warning2 = warning2Se;
      selectList = selectListSe;
    } else if (language == 'Spanish') {
      warning1 = warning1Es;
      warning2 = warning2Es;
      selectList = selectListEs;
    }
  }

  void getRecognisedText(XFile image) async {
    final prefs = await SharedPreferences.getInstance();
    mylist = prefs.getStringList(chosenlist) ?? [];

    
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

          if (mylist.contains(processedWord)) {
            warning = true;
            counter++;
            //wordsText = processedWord;
            //wordsText = wordsText + line.text + "\n";
            dangerousItemsDetected =
                dangerousItemsDetected + processedWord + "\n";
          }
        }
      }
    }

    textScanning = false;
    setState(() {});
  }

  void getImage(ImageSource source) async {

   if (chosenlist == "") {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(
        content: Text(selectList),
      ));
      return;
    }

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
      //       appBar: AppBar(
      //          iconTheme: IconThemeData(
      //   color: Colors.black, //change your color here
      // ),
      //         backgroundColor: Colors.white,
      //       // ignore: prefer_const_constructors
      //       title: Text('Your Own Lists' , style: TextStyle(color: Color.fromARGB(255, 11, 12, 12)), //<-- SEE HERE),
      //        )

      //     ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                    key: _dropdownFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              //borderSide: BorderSide(color:  Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            border: OutlineInputBorder(
                              //borderSide: BorderSide(color:   Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: false,
                            // fillColor:  Colors.green,
                          ),
                          validator: (value) =>
                              value == null ? "Select a list" : null,
                          //dropdownColor:  Colors.green,
                          value: selectedValue,
                          hint: Text(selectList),
                          onChanged: (String? newValue) {
                            setState(() {
                              chosenlist = newValue!;
                            });
                          },
                          items: _allLists
                              .map<DropdownMenuItem<String>>((String value) {
                            loadOptions();
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 41, 41, 41),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        // ElevatedButton(
                        //     onPressed: () {
                        //       if (_dropdownFormKey.currentState!.validate()) {
                        //          setState(() {
                        //           chosenlist = selectedValue!;
                        //         });
                        //       }
                        //     },
                        //     child: Text("Submit"))
                      ],
                    )),
                // DropdownButton<String>(
                //   value: _allLists.isEmpty
                //       ? null
                //       : chosenlist == ""
                //           ? _allLists.first
                //           : chosenlist,
                //   onChanged: (String? value) {
                //     setState(() {
                //       chosenlist = value!;
                //     });
                //   },
                //   items:
                //       _allLists.map<DropdownMenuItem<String>>((String value) {
                //     loadOptions();
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: Text(value ,
                //                 textAlign: TextAlign.center,
                //                 style: const TextStyle(
                //                 fontSize: 20.0,
                //                 fontWeight: FontWeight.bold,
                //                 color: Color.fromARGB(255, 41, 41, 41),
                //               ),
                //             ),
                //     );
                //   }).toList(),
                // ),

                const Padding(padding: EdgeInsets.only(bottom: 30)),

                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                  ),
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
                            "$warning1 ${counter.toString()} $warning2",
                            style: const TextStyle(fontSize: 20),
                          )
                        : Text(""),
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
                    // Text(
                    //   "Be careful, there are ${counter.toString()} dangerous substances in this item",
                    //   style: const TextStyle(fontSize: 20),
                    // ),
                  ],
                )
              ],
            )),
      )),
    );
  }
}
