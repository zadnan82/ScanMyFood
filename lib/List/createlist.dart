import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateList extends StatefulWidget {
  const CreateList({Key? key}) : super(key: key);

  @override
  _CreateListState createState() => _CreateListState();
}

class _CreateListState extends State<CreateList> {
  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  String instruction = "";
  String ingridientText = "";
  String listSaved = "";
  String nameExist = "";
  String fillAll = "";
  String listDeleted = "";
  final _ingredientsController = TextEditingController();
  List<String> ingredients = [];
  String listToShow = "";

  void _loadSelectedLanguage() async {
    String selectedLanguage = "";
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? "English";

    setState(() {
      selectedLanguage = language;
    });

    String instructionEn =
        "Create your own list by adding your unwanted additives one by one. Once you write an item click on the plus icon to add it to the list and then when you are done with all of the additives click on the save icon. The list will be saved in your device.  If you want to clear the list click on the eraser and to delete it from your device click on the trash icon.";
    String instructionSe =
       "Skapa din egen lista genom att lägga till dina oönskade tillsatser en efter en. När du har skrivit ett objekt klickar du på plusikonen för att lägga till det i listan och sedan när du är klar med alla tillsatser klickar du på spara-ikonen. Listan kommer att sparas i din enhet. Om du vill rensa listan klicka på radergummit och för att ta bort det från din enhet klicka på papperskorgen.";
    String instructionEs =
       "Cree su propia lista agregando los aditivos no deseados uno por uno. Una vez que escriba un elemento, haga clic en el icono más para agregarlo a la lista y luego, cuando haya terminado con todos los aditivos, haga clic en el icono de guardar. La lista se guardará en su dispositivo. Si desea borrar la lista, haga clic en el borrador y para eliminarla de su dispositivo, haga clic en el icono de la papelera.";
    String ingridientTextEn = "Ingredients i.e. chloride, sugar..";
    String ingridientTextSe = "Ingredienser som klorid, socker..";
    String ingridientTextEs = "Ingredientes, es decir, cloruro, azúcar...";
    String listSavedEn = "The list is saved on your device!";
    String listSavedSe = "Listan sparat på din enhet!";
    String listSavedEs = "¡La lista se guarda en su dispositivo!";
    String nameExistEn = "The name already exists";
    String nameExistSe = "Listnamnet finns redan";
    String nameExistEs = "El nombre de la lista ya existe.";
    String fillAllEn = "List is empty, write something to save!";
    String fillAllSe = "Listan är tom, skriv nåt för att spara!";
    String fillAllEs = "La lista está vacía, ¡escribe algo para guardar!";
    String listDeletedEn = "Your list is deleted!";
    String listDeletedSe = "Din lista är borttagen!";
    String listDeletedEs = "¡Tu lista ha sido eliminada!";

    if (selectedLanguage == 'English') {
      instruction = instructionEn;
      ingridientText = ingridientTextEn;
      listSaved = listSavedEn;
      nameExist = nameExistEn;
      fillAll = fillAllEn;
      listDeleted = listDeletedEn;
    } else if (language == 'Swedish') {
      instruction = instructionSe;
      ingridientText = ingridientTextSe;
      listSaved = listSavedSe;
      nameExist = nameExistSe;
      fillAll = fillAllSe;
      listDeleted = listDeletedSe;
    } else if (language == 'Spanish') {
      instruction = instructionEs;
      ingridientText = ingridientTextEs;
      listSaved = listSavedEs;
      nameExist = nameExistEs;
      fillAll = fillAllEs;
      listDeleted = listDeletedEs;
    }
  }

  void addIngredient() {
    final ingredient = _ingredientsController.text;
    if (ingredient.isNotEmpty) {
      setState(() {
        ingredients.add(ingredient.toLowerCase().trim());
        listToShow = listToShow + ingredient + ", ";
      });
      _ingredientsController.clear();
    }
  }

  checkInputs() {
    final myIngredients = ingredients;
    if (myIngredients.isEmpty) {
      Fluttertoast.showToast(
          msg: fillAll,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
           backgroundColor: Colors.orange,
          textColor: Colors.black,);
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text(fillAll),
      // ));
      return;
    }
    loadList();
  }

  Future<void> loadList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mylist', ingredients);
    clearInputFields();
  }

  void clearInputFields() {
    _ingredientsController.clear();
    setState(() {
      ingredients = [];
    });
    FocusManager.instance.primaryFocus?.unfocus();
    Fluttertoast.showToast(
        msg: listSaved,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
         backgroundColor: Colors.orange,
          textColor: Colors.black);
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(listSaved),
    // ));
    clearListtFields();
  }

  void clearListtFields() {
    //_ingredientsController.clear();
    setState(() {
      listToShow = "";
    });
  }

  void deleteAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mylist');
    FocusManager.instance.primaryFocus?.unfocus();
    Fluttertoast.showToast(
        msg: listDeleted,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
         backgroundColor: Colors.orange,
          textColor: Colors.black);

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(listDeleted),
    // ));

    //clearInputFields();
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


  return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
        child: Column(
          children: [
            SizedBox(height: screenSize.height * 0.05),
            Padding(
              padding: EdgeInsets.all(8.0 * textScaleFactor),
              child: Text(
                instruction,
                style: TextStyle(fontSize:  20.0 * textScaleFactor,),
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0 * textScaleFactor),
                    child: TextField(
                      controller: _ingredientsController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0 * textScaleFactor),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _ingredientsController.clear();
                          },
                          icon: Icon(
                            Icons.clear,
                            size: 20.0 * textScaleFactor,
                          ),
                        ),
                        hintText: ingridientText,
                        hintStyle: TextStyle(
                          fontSize: 24.0 * textScaleFactor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0 * textScaleFactor),
                  padding: EdgeInsets.only(top: 10.0 * textScaleFactor),
                  child: IconButton(
                    icon: Image.asset('assets/images/add.png'),
                    iconSize: screenSize.width * 0.1,
                    onPressed: () => addIngredient(),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.height * 0.01),

            Padding(
              padding: EdgeInsets.all(2.0 * textScaleFactor),
              child: Text(
                listToShow,
                style: TextStyle(fontSize: 24.0 * textScaleFactor),
              ),
            ),

            SizedBox(height: screenSize.height * 0.01),
           

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0 * textScaleFactor),
                  padding: EdgeInsets.only(top: 10.0 * textScaleFactor),
                  child: IconButton(
                    icon: Image.asset('assets/images/save.png'),
                    iconSize: screenSize.width * 0.1,
                    onPressed: () => checkInputs(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0 * textScaleFactor),
                  padding: EdgeInsets.only(top: 10.0 * textScaleFactor),
                  child: IconButton(
                    icon: Image.asset('assets/images/eraser.png'),
                    iconSize: screenSize.width * 0.1,
                    onPressed: () => clearListtFields(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0 * textScaleFactor),
                  padding: EdgeInsets.only(top: 10.0 * textScaleFactor),
                  child: IconButton(
                    icon: Image.asset('assets/images/trash.png'),
                    iconSize: screenSize.width * 0.1,
                    onPressed: () => deleteAllLists(),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.height * 0.03),
          ],
        ),
      ),
    ),
  );
}


}
