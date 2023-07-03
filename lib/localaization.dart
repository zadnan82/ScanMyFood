import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
// Text controllers for the input

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  // final userRef =
  //     FirebaseFirestore.instance.collection('users').withConverter<User>(
  //           fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
  //           toFirestore: (user, _) => user.toJson(),
  //         );
  bool _passwordVisible = false;
  Future<void> signInEmailAndPAssword() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Fill in your email and password please!"),
      ));
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text.trim());
      print("Successfully logged in ");
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Email address not found!"),
        ));
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Wrong password provided for this email!"),
        ));
        print('Wrong password provided for that user.');
      }
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print("USER ID $userId");
  }

  Future<void> resetPassword() async {
    if (_emailController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Fill in your email address!"),
      ));
    } else {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.toLowerCase().trim());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An email has been sent to you!"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.only(bottom: 50)),
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
                  icon: const Icon(Icons.clear)),
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
                  // Based on passwordVisible state choose the icon
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
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
            onPressed: resetPassword,
            child: const Text('Forgot Password?',
                style: TextStyle(fontSize: 16.0, color: Colors.black)),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 30)),
          Center(
            child: MaterialButton(
              minWidth: 150.0,
              height: 50,
              onPressed: signInEmailAndPAssword,
              color: Colors.grey,
              child: const Text('Sign in',
                  style: TextStyle(fontSize: 16.0, color: Colors.black)),
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 30))
        ],
      ),
    ));
  }
}