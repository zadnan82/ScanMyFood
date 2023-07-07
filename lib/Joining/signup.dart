import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../dbHelper/mongodb.dart';

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
        msg: "Please fill all the fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
          textColor: Colors.black,
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      Fluttertoast.showToast(
        msg: "Invalid email format",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
          textColor: Colors.black,
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      Fluttertoast.showToast(
        msg: "Password should be at least 6 characters long",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
          textColor: Colors.black,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.toLowerCase().trim(),
        password: _passwordController.text.trim(),
      );
      MongoDatabase.register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.toLowerCase().trim(),
      );
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
          msg: "Password is too weak!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.black,
        );
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
          msg: "Email already exists!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
           backgroundColor: Colors.orange,
          textColor: Colors.black,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Invalid email format",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
           backgroundColor: Colors.orange,
          textColor: Colors.black,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    // final double imageSize = screenWidth * 0.3;
    // final double titleFontSize = screenWidth * 0.05;
    // final double buttonFontSize = screenWidth * 0.04;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final textScaleFactor = screenWidth > 600
        ? 1.4
        : screenWidth < 500
            ? 0.8
            : 1.2; 

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
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.1,
              ),
              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 24.0 * textScaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  hintText: "First Name",
                  suffixIcon: IconButton(
                    onPressed: () {
                      _firstNameController.clear();
                    },
                    icon: Icon(Icons.clear),
                  ),
                   contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.03,
                        ),
                        hintStyle: TextStyle(fontSize: 18.0 * textScaleFactor), 
                      ),
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  hintText: "Last Name",
                  suffixIcon: IconButton(
                    onPressed: () {
                      _lastNameController.clear();
                    },
                    icon: Icon(Icons.clear),
                  ),
                 contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.03,
                        ),
                        hintStyle: TextStyle(fontSize: 18.0 * textScaleFactor), 
                      ),
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  hintText: "Email",
                  suffixIcon: IconButton(
                    onPressed: () {
                      _emailController.clear();
                    },
                    icon: Icon(Icons.clear),
                  ),
                   contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.03,
                        ),
                        hintStyle: TextStyle(fontSize: 18.0 * textScaleFactor), 
                      ),
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                 contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.03,
                        ),
                        hintStyle: TextStyle(fontSize: 18.0 * textScaleFactor), 
                      ),
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              
               Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        child: ElevatedButton(
                          onPressed: () {
                           createUserEmailAndPAssword();
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
