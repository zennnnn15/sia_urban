import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urbanchai/customer_side/main.dart';
import 'package:urbanchai/customer_side/menu.dart';


class CustomerSignIn extends StatefulWidget {
  @override
  _CustomerSignInState createState() => _CustomerSignInState();
}

class _CustomerSignInState extends State<CustomerSignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _loginWithEmailAndPassword() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigate to the next screen upon successful login.
      Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerLogin()));
    } catch (e) {
      print('Error: $e');
    }
  }

  void _oldUser(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerLogin()));
  }


  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        await _auth.signInWithCredential(credential);
        // Navigate to the next screen upon successful login.
        Navigator.push(context, MaterialPageRoute(builder: (context)=>MenuScreen()));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Urban Chai'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Register to Urban Chai',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _loginWithEmailAndPassword,
              child: Text('Login'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _loginWithGoogle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image.asset(
                  //   'assets/google_logo.png',
                  //   height: 24.0,
                  // ),
                  SizedBox(width: 12.0),
                  Text('Login with Google'),
                ],
              ),

            ),
        SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: _oldUser,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image.asset(
              //   'assets/google_logo.png',
              //   height: 24.0,
              // ),
              SizedBox(width: 12.0),
              Text('Old user?'),
            ],
          ),
        )
          ],
        ),
      ),
    );
  }
}
