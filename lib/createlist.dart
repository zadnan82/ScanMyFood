import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class CreateList extends StatefulWidget {
  const CreateList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
        "Create your own list by choosing a name for it and then add your unwanted additives one by one. Once you write an item click on the plus icon to add it to the list and then when you are done with all of the additives click on the save icon. The list will be saved in your device.  If you want to clear the list click on the eraser and to delete it from your device click on the trash icon.";
    String instructionSe =
       "Skapa din egen lista genom att välja ett namn för den och lägg sedan till dina oönskade tillsatser en efter en. När du har skrivit ett objekt tryck på plusikonen för att lägga till det i listan och sedan när du är klar med alla tillsatser tryck på spara-ikonen. Listan kommer att sparas i din enhet. Om du vill rensa listan tryck på suddgummit och för att ta bort den från din enhet tryck på papperskorgen.";
    String instructionEs =
       "Cree su propia lista eligiendo un nombre para ella y luego agregue los aditivos no deseados uno por uno. Una vez que escriba un elemento, haga clic en el ícono más para agregarlo a la lista y luego, cuando haya terminado con todos los aditivos, haga clic en el icono de guardar. La lista se guardará en su dispositivo. Si desea borrar la lista, haga clic en el borrador y para eliminarla de su dispositivo, haga clic en el icono de la papelera.";

    String ingridientTextEn = "Ingredients i.e. chloride, sugar..";
    String ingridientTextSe = "Ingredienser som klorid, socker..";
    String ingridientTextEs = "Ingredientes, es decir, cloruro, azúcar...";
    String listSavedEn = "The list is saved on your device!";
    String listSavedSe = "Listan sparat på din enhet!";
    String listSavedEs = "¡La lista se guarda en su dispositivo!";
    String nameExistEn = "The name already exists";
    String nameExistSe = "Listnamnet finns redan";
    String nameExistEs = "El nombre de la lista ya existe.";
    String fillAllEn = "Fill all the forms";
    String fillAllSe = "Fyll i alla formulär";
    String fillAllEs = "Rellena todos los formularios";
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
         listToShow = 
              listToShow + ingredient + ", ";
      });
      _ingredientsController.clear();
    }
  }

  checkInputs() {
    final myIngredients = ingredients;
    if (myIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(fillAll),
      ));
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(listSaved),
    ));
  }

  void clearListtFields() {
    _ingredientsController.clear();

    setState(() {
      ingredients = [];
    });
  }

  void deleteAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mylist');
    FocusManager.instance.primaryFocus?.unfocus();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(listDeleted),
    ));
    //clearInputFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(30.0)),
              Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                instruction,
                style: const TextStyle(fontSize: 15),
              ),),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              Row(
                children: [
                  Expanded(
                    child: 
                    Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                    TextField(
                      controller: _ingredientsController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                              onPressed: () {
                                _ingredientsController.clear();
                              },
                              icon: const Icon(Icons.clear)),
                          hintText: ingridientText),
                    ),
                  ),),
                  const Padding(padding: EdgeInsets.only(bottom: 20)),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.only(top: 10),
                    child: IconButton(
                      icon: Image.asset('assets/images/add.png'),
                      iconSize: 50,
                      onPressed: () => addIngredient(),
                    ),
                  ),
                ],
              ),
                 const Padding(padding: EdgeInsets.all(30.0)),

                 Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:Text(
                          listToShow,
                          style: const TextStyle(fontSize: 15),
                        ),
                    ),

               const Padding(padding: EdgeInsets.all(30.0)),
              // ListView.builder(
              //     shrinkWrap: true,
              //     padding: EdgeInsets.zero,
              //     itemCount: ingredients.length,
              //     itemBuilder: (_, i) {
              //       return Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Align(
              //           alignment: Alignment.center,
              //           child: Text(
              //             ingredients[i],
              //             textAlign: TextAlign.start,
              //             style: const TextStyle(
              //               fontSize: 14.0,
              //               color: Color.fromARGB(255, 41, 41, 41),
              //             ),
              //           ),
              //         ),
              //       );
              //     }),
              
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.only(top: 10),
                    child: IconButton(
                      icon: Image.asset('assets/images/save.png'),
                      iconSize: 50,
                      onPressed: () => checkInputs(),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.only(top: 10),
                    child: IconButton(
                      icon: Image.asset('assets/images/eraser.png'),
                      iconSize: 50,
                      onPressed: () => clearListtFields(),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.only(top: 10),
                    child: IconButton(
                      icon: Image.asset('assets/images/trash.png'),
                      iconSize: 50,
                      onPressed: () => deleteAllLists(),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 30)),
            ],
          ),
        ),
      ),
    );
  }
}
