import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyList extends StatefulWidget {
  const MyList({super.key});

  @override
  MyListState createState() => MyListState();
}

String selectList = "";
String warning1 = "";
String warning2 = "";

class MyListState extends State<MyList> {
  @override
  void initState() {
    super.initState();
    loadOptions();
    _loadSelectedLanguage();
  }
   String selectedLanguage = "";

  XFile? imageFile;
  int counter = 0;
  bool textScanning = false;
  bool warning = false;
  String message = "";
  String? language = "";
  String chosenlist = "";
  List<String> _mylist = [];
  List<String> mylist = [];
  List<String> words = [];
  String dangerousItemsDetected = "";
  final _dropdownFormKey = GlobalKey<FormState>();
  String? selectedValue = null;

 String textEn =
      "Here you will use our standard list of dangerous items! Click on the camera icon to scan the ingridents text of the product or on the gallery icon to access your device album. To create your own list click on the pen in the bottom and then the little man icon down there to use your own list of items!";
  String textSe =
      "Här kommer du att använda vår standardlista över farliga föremål! Klicka på kameraikonen för att skanna produktens innehållstext eller på galleriikonen för att komma åt ditt enhetsalbum. För att skapa din egen lista klicka på pennan i botten och sedan den lilla man-ikonen där nere för att använda din egen lista med föremål!";
  String textEs =
      "¡Aquí usará nuestra lista estándar de elementos peligrosos! Haga clic en el ícono de la cámara para escanear el texto de los componentes del producto o en el ícono de la galería para acceder al álbum de su dispositivo. Para crear su propia lista, haga clic en el bolígrafo en la parte inferior y luego ¡el ícono del hombrecito ahí abajo para usar tu propia lista de elementos!";
 

  Future<void> loadOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final mylist = prefs.getStringList('mylist') ?? [];
    setState(() {
      _mylist = mylist;
    });
  }

  void _loadSelectedLanguage() async {
   
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language');
    if (language != null) {
      setState(() {
        selectedLanguage = language;
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
    mylist = prefs.getStringList('mylist') ?? [];

    
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

  //  if (chosenlist == "") {
  //     ScaffoldMessenger.of(context).showSnackBar( SnackBar(
  //       content: Text(selectList),
  //     ));
  //     return;
  //   }

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
        child:
        Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [ 
      




DecoratedBox(
  decoration: BoxDecoration( 
     color:Colors.lightGreen, //background color of dropdown button
     border: Border.all(color: Colors.black38, width:3), //border of dropdown button
     borderRadius: BorderRadius.circular(50), //border raiuds of dropdown button
     boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                blurRadius: 5) //blur radius of shadow
          ]
  ),
  


             
                child: PhysicalModel(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    shadowColor: Color.fromARGB(255, 2, 2, 2),
                    color: Colors.white,
                    child: 
                    Padding(
    padding: EdgeInsets.only(left:30, right:30),
     child: DropdownButton<String>(
                    hint: Text("Your list"), 
                      onChanged: (String? value) {
                        setState(() { 
                        });
                      },
                      items:
                          _mylist.map<DropdownMenuItem<String>>((String value) {
                        loadOptions();
                        return DropdownMenuItem<String>(
                          value: value,
                          child:  
                          Padding(
                                    padding: EdgeInsets.only(left: 50 , right: 45),
                                    child:  Text(value ,
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
                  icon: const Padding( //Icon at tail, arrow bottom is default icon
                  padding: EdgeInsets.only(left:20 , right: 20),
                  child:Icon(Icons.arrow_drop_down)
                ), 
                iconEnabledColor: Colors.black, //Icon color
                iconSize: 30,
        
                ),
                ),

),),
               const Padding(padding: EdgeInsets.only(bottom: 20)),

                  //   Form(
                  // key: _dropdownFormKey,
                  // child: 
                  // Center( 
                  //   child:
                  //     DropdownButtonFormField(
                  //       decoration: 
                  //       InputDecoration(
                  //         enabledBorder: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(20),
                  //         ),
                  //         border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(20),
                  //         ),
                  //         filled: false,
                  //       ),  
                  //       hint: const Center(
                  //         child: 
                  //         Text("My list" ,textAlign: TextAlign.center ),
                  //         ),
                  //       onChanged: (String? selectlist) {
                  //          setState(() {});
                  //       },
                  //       items: _mylist.map<DropdownMenuItem<String>>((String value) {
                  //         loadOptions();
                  //         return DropdownMenuItem<String>(
                  //           value: value,
                  //           child: Center(
                  //             child:
                  //               Text(
                  //             value, 
                  //             style: const TextStyle(
                  //               fontSize: 15.0,
                  //               fontWeight: FontWeight.normal,
                  //               color: Color.fromARGB(255, 41, 41, 41),
                  //             ),
                  //           ),                             
                  //           )
                  //         );
                  //       }
                  //       ).toList(),
                  //     ),                   
                  // )
                  // ),
            
            //     DropdownButtonFormField(
            //   decoration: InputDecoration(
            //       border: OutlineInputBorder(
            //         borderRadius: const BorderRadius.all(
            //           const Radius.circular(30.0),
            //         ),
            //       ),
            //       filled: true,
            //       hintStyle: TextStyle(color: Colors.white),
            //       hintText: "Name",
            //       fillColor: Color.fromARGB(255, 253, 254, 254)),
            //   //value: dropDownValue,
            //   onChanged: (String? Value) {
            //     setState(() {
                  
            //     });
            //   },items: _mylist
            //       .map((cityTitle) => DropdownMenuItem(
            //           value: cityTitle, child: Text("$cityTitle")))
            //       .toList(),
            // ),
          
        
                const Padding(padding: EdgeInsets.only(bottom: 30)),

                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  selectedLanguage == 'English'
                      ? Text(textEn)
                      : selectedLanguage == 'Swedish'
                          ? Text(textSe)
                          : selectedLanguage == 'Spanish'
                              ? Text(textEs)
                              : Text(textEn),

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
