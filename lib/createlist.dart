import 'dart:developer';
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ffi';
import 'package:flutter/services.dart';

import 'editlist.dart';

class CreateList extends StatefulWidget {
  const CreateList({Key? key}) : super(key: key);

  @override
  _CreateListState createState() => _CreateListState();
}

class _CreateListState extends State<CreateList> {
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Fill all the forms"),
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
        const SnackBar(content: Text("The name already exists")),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Your list is saved on your device!"),
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
              const Text("Create new list",
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
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
                    hintText: "List name"),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              Row(
                children: [
                  Expanded(child:  TextField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _ingredientsController.clear();
                        },
                        icon: const Icon(Icons.clear)),
                    hintText: "Ingredients i.e. chloride, sugar.."),
              ),),
               
              const Padding(padding: EdgeInsets.only(bottom: 20)),

              Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child:   IconButton(
                icon: Image.asset('assets/images/add.png'),
                iconSize: 50,
                onPressed: () => addIngredient(),
              ),
              ),
                ],
              )
             ,
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: ingredients.length,

                  itemBuilder: (_, i) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                              alignment: Alignment.center, // Align however you like (i.e .centerRight, centerLeft)
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
                        child:  IconButton(
                icon: Image.asset('assets/images/save.png'),
                iconSize: 50,
                onPressed: () => checkInputs(),
              ),),
                 
                  Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child:  IconButton(
                icon: Image.asset('assets/images/trash.png'),
                iconSize: 50,
                onPressed: () => clearListtFields(),
              ),),
                 
                ],
              ), 
               const Padding(padding: EdgeInsets.only(top: 30)),
          
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Next(),
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