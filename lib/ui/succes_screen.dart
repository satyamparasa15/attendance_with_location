import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Alert Me", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Image.asset(
              'assets/tick_green.png',
              width: 200,
              height: 200,
              scale: 0.5,
            ),
            Text(
              "Your Attendance marked", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
