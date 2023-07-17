import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanmyfood/dbHelper/mongodb.dart';

class SignOut extends StatefulWidget {
  @override
  State<SignOut> createState() => _SignOutState();
}

class _SignOutState extends State<SignOut> {
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Fluttertoast.showToast(
        msg: "Logged out successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
          textColor: Colors.black);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  Future<void> DeleteAccount() async {
    var user = FirebaseAuth.instance.currentUser;
    MongoDatabase.deleteAccount(user!.email.toString());
    await user.delete();
    signOut();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width; 
  final textScaleFactor = screenWidth > 600
        ? 1.4
        : screenWidth < 500
            ? 0.8
            : 1.2;  

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Sign Out'),
      // ),
      body: Padding(
        padding: EdgeInsets.all(20.0 * textScaleFactor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/images/warning.png"),
              width: screenSize.width * 0.1,
            
            ),
            SizedBox(height: 20.0 * textScaleFactor),
            Text(
              'Are you sure you want to sign out?',
              style: TextStyle(fontSize: 24.0 * textScaleFactor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.0 * textScaleFactor),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 
                 Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                        '/', (Route<dynamic> route) => false);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Text(
        
                              'Cancel',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                SizedBox(width: 20.0 * textScaleFactor),
               
                     ElevatedButton(
                            onPressed: () {
                              signOut();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Text(
                                'Sign Out',
                                style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black),
                              ),
                            )), 
              ],
            ),
            SizedBox(height: 20.0 * textScaleFactor),
            ElevatedButton(
               onPressed: () {
                DeleteAccount();
              },
               child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Text( 
                'Delete Your account',
                style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black),
                              
              )),
              
            ),
          ],
        ),
      ),
    );
  }
}
