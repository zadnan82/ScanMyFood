import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dbHelper/mongodb.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  Future<void> createUserEmailAndPAssword() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {

           Fluttertoast.showToast(
        msg:  "Please fill all the fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white);
 
      return;
    }

      if (!_emailController.text.contains('@')) {

          Fluttertoast.showToast(
        msg:  "Invalid email format",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white);

      
      return;
    }

    if (_passwordController.text.length < 6) { 
       Fluttertoast.showToast(
        msg:  "Password should be at least 6 characters long",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white);
      return;
    }


    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.toLowerCase().trim(),
        password: _passwordController.text.trim(),
      );
      MongoDatabase.register(_firstNameController.text.trim(),
          _lastNameController.text.trim(), _emailController.text.toLowerCase().trim());
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
         Fluttertoast.showToast(
        msg:  "Password is too weak!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white); 
      } else if (e.code == 'email-already-in-use') {
         Fluttertoast.showToast(
        msg:  "Email already exists!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white); 
         
      }

      else   {
         Fluttertoast.showToast(
        msg:  "Invalid email format",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white); 
         
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              const Text(
                'Sign Up',
                style: TextStyle(
                    fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: "First Name",
                  suffixIcon: IconButton(
                    onPressed: () {
                      _firstNameController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: "Last Name",
                  suffixIcon: IconButton(
                    onPressed: () {
                      _lastNameController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: "Email",
                  suffixIcon: IconButton(
                    onPressed: () {
                      _emailController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              Center(
                child: ElevatedButton(
                  onPressed: createUserEmailAndPAssword,
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
            ],
          ),
        ),
      ),
    );
  }
}
