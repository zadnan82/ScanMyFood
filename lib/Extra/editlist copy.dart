import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ffi';
import 'package:flutter/services.dart';

class EditList2 extends StatefulWidget {
  const EditList2({Key? key}) : super(key: key);

  @override
  _EditList2State createState() => _EditList2State();
}

class _EditList2State extends State<EditList2> {
  @override
  void initState() {
    super.initState();
    loadOptions();
  }

  List<String> _allLists = [];

  Future<void> loadOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final all = prefs.getStringList('all') ?? [];
    setState(() {
      _allLists = all;
    });
  }

  void deleteAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    loadOptions();
  }

  void deleteList(listname, i) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(listname);

    final totalListsOld = prefs.getStringList("all") ?? [];
    totalListsOld.removeAt(i);

    await prefs.setStringList("all", totalListsOld);

    loadOptions();
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
              const Text("Delete your lists",
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _allLists.length,
                  itemBuilder: (_, i) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Padding(padding: EdgeInsets.only(right: 20)),
                            const Image(
                              image: AssetImage("assets/images/mylist.png"),
                              height: 40,
                              width: 40,
                            ),
                            const Padding(padding: EdgeInsets.only(right: 20)),
                            Text(
                              _allLists[i],
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 41, 41, 41),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(right: 150)),
                            IconButton(
                              icon: Image.asset('assets/images/cancel.png'),
                              iconSize: 40,
                              onPressed: () {
                                deleteList(_allLists[i], i);
                              },
                            ),
                          ],
                        ));
                  }),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              IconButton(
                icon: Image.asset('assets/images/trash.png'),
                iconSize: 50,
                onPressed: () => deleteAllLists(),
              ),
              const Padding(padding: EdgeInsets.only(right: 50)),
            ],
          ),
        ),
      ),
    );
  }
}