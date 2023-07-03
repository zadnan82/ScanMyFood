import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scanmyfood/signin.dart';
import 'home_page.dart'; 

// ignore: must_be_immutable
class LandingPage extends StatelessWidget {
  // Assume this boolean value is set based on user authentication status
  bool isLoggedIn = false;


 bool checkifLoggedin() {
    if (FirebaseAuth.instance.currentUser?.uid != null) {    
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (checkifLoggedin()) {
      return HomePage();
    } else {
      return SignIn();
    }
  }
}
