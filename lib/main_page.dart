import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: ElevatedButton(
           
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => Scaffold(
                      appBar: AppBar(
                        title: const Text('New Page'),
                      ),
                    )));
          },
          child: const Text("Move to new page"),
        ),
      ),
    );
  }
}