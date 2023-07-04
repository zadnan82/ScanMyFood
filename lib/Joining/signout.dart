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
        backgroundColor: Colors.black,
        textColor: Colors.white);
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
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Sign Out'),
      // ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/images/warning.png"),
              width: 50,
              height: 50,
            ),
            SizedBox(height: 20),
            Text(
              'Are you sure you want to sign out?',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text('Cancel' , style: TextStyle(fontSize: 16.0, color: Colors.black),),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/', (Route<dynamic> route) => false);
                  },
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  ),
                  onPressed: () {
                    signOut();
                  },
                ),
              ],
            ),

                     const Padding(padding: EdgeInsets.only(bottom: 20)),
                     
            ElevatedButton(
              child: Text(
                'Delete Your account',
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              onPressed: () {
                DeleteAccount();
              },
            ),
          ],
        ),
      ),
    );
  }
}
