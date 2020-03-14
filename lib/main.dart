import 'package:alert_me_attendence/ui/home_screen.dart';
import 'package:alert_me_attendence/ui/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primaryColor: Colors.green, accentColor: Colors.green),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 5,
      image: Image.asset(
        'assets/logo.png',
      ),
      title: Text(
        "Welcome to Alert me",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
      navigateAfterSeconds: FutureBuilder(

        future: FirebaseAuth.instance.currentUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.hasData) {
            print("dkfdfkdfhkdhf");
            return HomeScreen();
          } else {
            print("else else");
            return LoginScreen();
          }
        },
      ),
      loadingText: Text(
        "Attendance monitoring system",
        style: TextStyle(color: Colors.black45),
      ),
      backgroundColor: Colors.white,
      photoSize: 100.0,
      loaderColor: Colors.green,
    );
  }

  isUserSignIn() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    firebaseAuth.currentUser().then((user) {
      return true;
    });

    return false;
  }
}