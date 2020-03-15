import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
 Dio  dio = new Dio();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test screen"),
      ),
    body: Container(
        child: GestureDetector(child: Text("send data",), onTap: (){
          print("onTapped");
          sendData();
        },),
    ),);
  }

  Future<void> sendData() async {
    dio.post("http://www.flutterant.com/alert_me/conn.php",
        data: {"email": "test@gmail.com", "name1": "testing", "time": "12:00",
          "date1": "set-20-2020", "status": true}).then((response){
            print("responser is ${response.data}");
    });

  }
}
