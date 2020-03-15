import 'package:alert_me_attendence/ui/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Alert Me",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              width: 200,
              height: 200,
              scale: 0.6,
            ),
            SizedBox(
              height: 20,
            ),
            GoogleSignInButton(
              onPressed: () {
                signInWithGoogle();
              },
              darkMode: false, // default: false
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "* Please sign up with Depatment Google account",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            SizedBox(
              height: 8,
            ),
            Text("Alert Me takes your information",
                style: TextStyle(color: Colors.black54, fontSize: 12))
          ],
        ),
      ),
    );
  }

  Future signInWithGoogle() async {
    print("in sign method...");
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    if (user != null) {
      Future.delayed(Duration(seconds: 1), (){
        insertAttendanceData();
      });

      final FirebaseUser user = await _auth.currentUser();

      print("Current user data ${user.toString()}");
      print("User name ---------${user.displayName}");
     // insertRecord(user);

    }
  }

//  void insertRecord(FirebaseUser user) async{
//    print("in Insert record method-----");
//   await  databaseReference.collection("users")
//    .document("my doc")
//    .setData({
//      'email': user.email,
//      'name':user.displayName,
//      'phone':user.phoneNumber,
//     'department':''
//    });
//   print("before navigationss.......");
//    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//      return HomeScreen();
//    }));
//    print("after navigations........");
//  }

  void insertAttendanceData() {
    print("ingjhgjjfhggy");
    FirebaseAuth auth = FirebaseAuth.instance;
    final databaseReference = Firestore.instance;
    auth.currentUser().then((user) async {
      print("insert data");
      await databaseReference
          .collection("users")
          .document(user.uid)
        . setData({
        'email': user.email,
        'name': user.displayName,
        'phone':user.phoneNumber,
        'department':''
      }).then((val) {
        print("the value is after attendance ");
        Future.delayed(
            Duration(
              seconds: 1,
            ), () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      });
    });
  }
}
