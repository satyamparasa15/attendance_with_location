import 'package:alert_me_attendence/ui/succes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceMarkScreen extends StatefulWidget {
  @override
  _AttendanceMarkScreenState createState() => _AttendanceMarkScreenState();
}

class _AttendanceMarkScreenState extends State<AttendanceMarkScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _hasFingerPrintSupport = false;
  String _authorizedOrNot = "Not Authorized";
  bool isAuthenticated = false;
  List<BiometricType> _availableBuimetricType = List<BiometricType>();

  Future<void> _getBiometricsSupport() async {
    // 6. this method checks whether your device has biometric support or not
    bool hasFingerPrintSupport = false;
    try {
      hasFingerPrintSupport = await _localAuthentication.canCheckBiometrics;
    } catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _hasFingerPrintSupport = hasFingerPrintSupport;
    });
  }

  Future<void> _getAvailableSupport() async {
    // 7. this method fetches all the available biometric supports of the device
    List<BiometricType> availableBuimetricType = List<BiometricType>();
    try {
      availableBuimetricType =
          await _localAuthentication.getAvailableBiometrics();
    } catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _availableBuimetricType = availableBuimetricType;
    });
  }

  Future<void> _authenticateMe() async {
    // 8. this method opens a dialog for fingerprint authentication.
    //    we do not need to create a dialog nut it popsup from device natively.
    bool authenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: "Authenticate for Attendance", // message for dialog
        useErrorDialogs: true, // show error in dialog
        stickyAuth: true, // native process
      );
    } catch (e) {
      print(e);
    }
    if (isAuthenticated) {
      insertAttendanceData();
    } else {
      print("not authenticated....");
    }
//    if (!mounted) return;
//    setState(() async {
//      _authorizedOrNot = authenticated ? "Authorized" : "Not Authorized";
//      if (authenticated) {
//        await Future.delayed(
//            new Duration(
//              milliseconds: 500,
//            ), () {
//          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//            return SuccessScreen();
//          }));
//        });
//      }
//    });
  }

  @override
  void initState() {
    _getBiometricsSupport();
    _getAvailableSupport();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Attendance Mark", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              "Please Tap here...",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: 16),
            ),
            SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: () {
                print("Tapped");
                _authenticateMe();
              },
              child: Image.asset(
                'assets/logo.png',
                width: 200,
                height: 100,
                scale: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void insertAttendanceData() {
    FirebaseAuth auth = FirebaseAuth.instance;
    final databaseReference = Firestore.instance;
    auth.currentUser().then((user) async {
      await databaseReference
          .collection("attendance")
          .document(user.uid)
          .setData({
        'email': user.email,
        'name': user.displayName,
        'isPresent': true,
        'date': DateTime.now()
      }).then((val) {
        print("the value is after attendance ");
        Future.delayed(
            Duration(
              seconds: 1,
            ), () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return SuccessScreen();
          }));
        });
      });
    });
  }
}
