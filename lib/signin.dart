import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanmyfood/signup.dart';
import 'package:url_launcher/url_launcher.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
// Text controllers for the input

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  bool _passwordVisible = false;
 

  Future<void> signInEmailAndPassword(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg:  "Fill in your email and password please!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white);  
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );
      print("Successfully logged in");
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
         Fluttertoast.showToast(
        msg:  "Email address not found!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white);    
      } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(
        msg:  "Wrong password provided for this email!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white);   
      }
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print("USER ID $userId");
  }

  Future<void> resetPassword(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Fill in your email address!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white);
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: _emailController.text.toLowerCase().trim(),
    ); 
    Fluttertoast.showToast(
        msg: "An email has been sent to you!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 50)),
              const Text(
                'Check My Food Ingredients',
                style: TextStyle(
                    fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(
                          'https://firebasestorage.googleapis.com/v0/b/giggli-df121.appspot.com/o/private%2Fone--orange---with-white-background-with-good-padding-around-it%20(2).png?alt=media&token=9167da9e-a8f2-47d7-89ca-1b95d40a52b5'),
                      fit: BoxFit.fill),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              GestureDetector(
                onTap: () async {
                  if (Platform.isAndroid || Platform.isIOS) {
                    final appId = Platform.isAndroid
                        ? 'com.zainabadnan.scanmylotions'
                        : 'id6447474601';
                    final url = Uri.parse(
                      Platform.isAndroid
                          ? "market://details?id=$appId"
                          : "https://apps.apple.com/app/id$appId",
                    );
                    launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  }

                  if (!await launchUrl(
                      Uri.parse(
                          "https://play.google.com/store/apps/details?id=com.zainabadnan.scanmylotions"),
                      mode: LaunchMode.externalApplication)) {
                    throw 'Could not launch ';
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'If you have an account in our Cosmetics Checker app',
                        style: TextStyle(fontSize: 12.0, color: Colors.black),
                      ),
                      const Text(
                        'You don\'t need to create one, sign in directly!',
                        style: TextStyle(fontSize: 12.0, color: Colors.black),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/giggli-df121.appspot.com/o/private%2Fapplogo.png?alt=media&token=1cba3d23-ef1c-433c-8bef-dfdf8b1a7e2e'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const Text(
                        'Cosmetics Checker',
                        style: TextStyle(fontSize: 12.0, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
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
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                  ),
                ),
              ),
              
              
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              MaterialButton( 
                minWidth: 150.0,
                height: 50,
                onPressed: () => resetPassword(context),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 12.0, color: Colors.black),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton( 
                    onPressed: () => signInEmailAndPassword(context),               
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    child: Text('Register'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUp(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
            ],
          ),
        ),
      ),
    );
  }
}
