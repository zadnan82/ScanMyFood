 import 'package:flutter/material.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import '../editlist.dart';

class CreateList2 extends StatefulWidget {
  const CreateList2({Key? key}) : super(key: key);

  @override
  _CreateList2State createState() => _CreateList2State();
}

String instruction = "";
String listName = "";
String ingridientText = "";
String listSaved = "";
String nameExist = "";
String fillAll = "";

class _CreateList2State extends State<CreateList2> {
  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  void _loadSelectedLanguage() async {
    String selectedLanguage = "";
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language');
    if (language != null) {
      setState(() {
        selectedLanguage = language;
      });
    }

    String instructionEn =
        "Create your own list by choosing a name for it and then add the items one by one. Once you write an item click on the plus icon to add it to the list and then when you are done click on the save icon.  If you want to clear the list click on the trash icon.";
    String instructionSe =
        "Skapa din egen lista genom att välja ett namn för den och lägg sedan till objekten en efter en. När du har skrivit ett objekt klicka på plusikonen för att lägga till det i listan och klicka sedan på sparaikonen när du är klar. Om du vill rensa listan klicka på papperskorgen.";
    String instructionEs =
        "Cree su propia lista eligiendo un nombre para ella y luego agregue los elementos uno por uno. Una vez que escriba un elemento, haga clic en el ícono más para agregarlo a la lista y luego, cuando haya terminado, haga clic en el ícono Guardar. Si desea borrar la lista, haga clic en el icono de la papelera.";
    String listNameEn = "List Name";
    String listNameSe = "Namnlista";
    String listNameEs = "Lista de nombres";
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

    if (language == null || selectedLanguage == 'English') {
      instruction = instructionEn;
      listName = listNameEn;
      ingridientText = ingridientTextEn;
      listSaved = listSavedEn;
      nameExist = nameExistEn;
      fillAll = fillAllEn;
    } else if (language == 'Swedish') {
      instruction = instructionSe;
      listName = listNameSe;
      ingridientText = ingridientTextSe;
      listSaved = listSavedSe;
      nameExist = nameExistSe;
      fillAll = fillAllSe;
    } else if (language == 'Spanish') {
      instruction = instructionEs;
      listName = listNameEs;
      ingridientText = ingridientTextEs;
      listSaved = listSavedEs;
      nameExist = nameExistEs;
      fillAll = fillAllEs;
    }
  }

  final _nameController = TextEditingController();
  final _ingredientsController = TextEditingController();

  List<String> ingredients = [];

  void addIngredient() {
    final ingredient = _ingredientsController.text;
    if (ingredient.isNotEmpty) {
      setState(() {
        ingredients.add(ingredient.toLowerCase().trim());
      });

      _ingredientsController.clear();
    }
  }

  checkInputs() {
    final listName = _nameController.text;
    final myIngredients = ingredients;

    if (listName == "" || myIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(
        content: Text(fillAll),
      ));
      return;
    }

    loadList(listName);
  }

  Future<void> loadList(String listName) async {
    final prefs = await SharedPreferences.getInstance();
    final totalListsOld = prefs.getStringList("all") ?? [];

    if (totalListsOld.contains(listName)) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nameExist)),
      );
      return;
    }

    totalListsOld.add(listName);
    await prefs.setStringList("all", totalListsOld);

    await prefs.setStringList(listName, ingredients);

    clearInputFields();
  }

  void clearInputFields() {
    _nameController.clear();
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
    _nameController.clear();
    _ingredientsController.clear();

    setState(() {
      ingredients = [];
    });
  }

  void deleteAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    clearInputFields();
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
              Text(
                instruction,
                style: const TextStyle(fontSize: 15),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _nameController.clear();
                        },
                        icon: const Icon(Icons.clear)),
                    hintText: listName),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                  ),
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
              ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: ingredients.length,
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment
                            .center, // Align however you like (i.e .centerRight, centerLeft)
                        child: Text(
                          ingredients[i],
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Color.fromARGB(255, 41, 41, 41),
                          ),
                        ),
                      ),
                    );
                  }),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
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
                      icon: Image.asset('assets/images/trash.png'),
                      iconSize: 50,
                      onPressed: () => clearListtFields(),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 30)),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditList(),
                    ),
                  );
                },
                child: const Text('Edit Your Lists'),
              ),
              const Padding(padding: EdgeInsets.only(right: 50)),
            ],
          ),
        ),
      ),
    );
  }
}
