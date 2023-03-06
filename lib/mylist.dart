import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyList extends StatefulWidget {
  const MyList({super.key});

  @override
  MyListState createState() => MyListState();
}

class MyListState extends State<MyList> {
 

  @override
  void initState() {
    super.initState();
    loadOptions();
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

  void getRecognisedText(XFile image) async {
    final prefs = await SharedPreferences.getInstance();
     
    mylist =  prefs.getStringList(chosenlist) ?? [];

    if (mylist == []) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You have to chose a list"),
      ));
      return;
    }

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
            message = "warning";
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
        appBar: AppBar(
           iconTheme: IconThemeData(
    color: Colors.black, //change your color here
  ),
          backgroundColor: Colors.white,
        // ignore: prefer_const_constructors
        title: Text('Your Own Lists' , style: TextStyle(color: Color.fromARGB(255, 11, 12, 12)), //<-- SEE HERE),
         )
        
      ),
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
                validator: (value) => value == null ? "Select a country" : null,
                //dropdownColor:  Colors.green,
                value: selectedValue,
                 hint:  Text("Select a List"),
                onChanged: (String? newValue) {
                   setState(() {
                      chosenlist = newValue!;
                    });
                },
                items: _allLists.map<DropdownMenuItem<String>>((String value) {
                    loadOptions();
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value , 
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 41, 41, 41),
                              ),
                            ),
                    );
                  }).toList(),),
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
                        child:  IconButton(
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
                        child:  IconButton(
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
                            "${message}, be careful!! there are ${counter.toString()} dangerous substances in this item",
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