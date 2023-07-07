import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanmyfood/Joining/signup.dart';
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
      msg: "Fill in your email and password please!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.black,
    );
    return;
  }

  final email = _emailController.text.trim().toLowerCase();

  if (!_isValidEmailFormat(email)) {
    Fluttertoast.showToast(
      msg: "Fill in correct email format!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.black,
    );
    return;
  }

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: _passwordController.text.trim(),
    );
    print("Successfully logged in");
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      Fluttertoast.showToast(
        msg: "Email address not found!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.black,
      );
    } else if (e.code == 'wrong-password') {
      Fluttertoast.showToast(
        msg: "Wrong password provided for this email!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.black,
      );
    }
  }

  final userId = FirebaseAuth.instance.currentUser?.uid;
  print("USER ID $userId");
}

bool _isValidEmailFormat(String email) {
  // A simple email format validation using a regular expression
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  return emailRegex.hasMatch(email);
}

  Future<void> resetPassword(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Fill in your email address!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
         backgroundColor: Colors.orange,
          textColor: Colors.black,
      );
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: _emailController.text.toLowerCase().trim(),
    );
    Fluttertoast.showToast(
      msg: "An email has been sent to you!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
          textColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;
        final textScaleFactor = screenWidth > 600
            ? 1.4
            : screenWidth < 500
                ? 0.8
                : 1.2; 

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.only(bottom: screenHeight * 0.1)),
                  Text(
                    'Check My Food Ingredients',
                    style: TextStyle(
                        fontSize: 24.0 * textScaleFactor,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.03)),
                  Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/app_logo.png'),
                        fit: BoxFit.fill,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange,
                          blurRadius: 4,
                          offset: Offset(4, 8), // Shadow position
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.03)),
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
                          Text(
                            'If you have an account in our Cosmetics Checker app',
                            style: TextStyle(fontSize: 15.0 * textScaleFactor),
                          ),
                          Text(
                            'You don\'t need to create one, sign in directly!',
                            style: TextStyle(fontSize: 15.0 * textScaleFactor),
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.only(bottom: screenHeight * 0.01)),
                          Container(
                            width: screenWidth * 0.06,
                            height: screenWidth * 0.06,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/cosmeticsapplogo.png'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  bottom: screenHeight * 0.005)),
                          Text(
                            'Cosmetics Checker',
                            style: TextStyle(
                              fontSize: 16.0 * textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.03)),
                 TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                        hintText: "Email",
                        suffixIcon: IconButton(
                          onPressed: () {
                            _emailController.clear();
                          },
                          icon: Icon(Icons.clear),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.025,
                          horizontal: screenWidth * 0.03,
                        ),
                        hintStyle: TextStyle(fontSize: 18.0 * textScaleFactor), 
                      ),
                    ),

                  Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.04)),
                  TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e., toggle the state of the passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.025,
                          horizontal: screenWidth * 0.03,
                        ),
                        hintStyle: TextStyle(fontSize: 18.0 * textScaleFactor), 
                      ),
                    ),

                  Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.001)),
                  MaterialButton(
                    minWidth: screenWidth * 0.15,
                    height: screenHeight * 0.05,
                    textColor: Colors.orange,
                    onPressed: () => resetPassword(context),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                          fontSize: 14.0 * textScaleFactor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.01)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        child: ElevatedButton(
                          onPressed: () {
                            signInEmailAndPassword(context);
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUp(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black),
                              ),
                            )),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse(
                            "https://zainabadnanpolicies.azurewebsites.net/food"));
                      },
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.orange, // Customize the link color
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.04)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
