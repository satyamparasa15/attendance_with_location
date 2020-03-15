import 'dart:convert';

import 'package:alert_me_attendence/ui/show_attendance_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'attendance_mark_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var imageUrl = "https://image.flaticon.com/icons/png/512/61/61205.png";

  String name;
  String currentAddress = '';
  double collegeLat = 17.43504;
  double collegeLog = 78.44181;
  bool isLoading = false;
  bool isInTime = false;
  bool isLocationMatch = false;

  @override
  void initState() {
    showUseData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("Home", style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 60,
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Hi, $name",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Welcome to Alert Me",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 32,
                    ),
                    _markAttendance(),
                    SizedBox(
                      height: 16,
                    ),
                    _showAttendance(),
                    SizedBox(
                      height: 20,
                    ),
                    _showOtherProfiles(),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20.0, right: 20, top: 24),
                      child: isLoading
                          ? CircularProgressIndicator(
                              backgroundColor: Colors.red,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                  Text("Current Location:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54)),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(currentAddress,
                                      style: TextStyle(color: Colors.black54))
                                ]),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showUseData() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    firebaseAuth.currentUser().then((user) {
      setState(() {
        imageUrl = user.photoUrl;
        name = user.displayName;
      });
    });
  }

  Widget _markAttendance() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        setState(() {
          isLoading = true;
        });
        // isAttendanceMarked();
        getUserLocation();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Mark Attendance  ',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _showAttendance() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ShowAttendanceScreen();
        }));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("assets/list.png"),
              height: 35.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Show Attendance  ',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showOtherProfiles() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        sendData();
        print("onpress clicked......");
        DateFormat dateFormat = DateFormat("dd-MMM-yyyy");
        String string = dateFormat.format(DateTime.now());
        print("formated date $string");
        DateFormat timeFormat = DateFormat('hh:mm a');
        String time = timeFormat.format(DateTime.now());
        print("Foramted time $time");
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("assets/group.png"),
              height: 35.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'View Other Profiles',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Position> locateUser() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() {
    locateUser().then((location) async {
      setState(() {
        isLoading = false;
      });
      double distanceInMeters = await Geolocator().distanceBetween(
          location.latitude, location.longitude, collegeLat, collegeLog);
      print("distance in meters:$distanceInMeters");
      if (distanceInMeters < 50) {
        setState(() {
          isLocationMatch = true;
        });
      }
      DateTime now = new DateTime.now();
      DateTime fixedDate =
          new DateTime(now.year, now.month, now.day,40 , 27, 0);
      DateTime currentDate = DateTime.now();
      isInTime = currentDate.isBefore(fixedDate);
      print("time checking ..$isInTime  and location:$isLocationMatch");
      print("is location check $isLocationMatch");
      print("Time differnces ${fixedDate.difference(currentDate).inSeconds}");
      isConstrainsMatched();
      getAddressLine(location);
    });
  }

  Future<void> getAddressLine(Position location) async {
    final coordinates = new Coordinates(location.latitude, location.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      currentAddress = addresses.first.addressLine.toString();
    });
    print("${addresses.first.addressLine}");
  }

  Future<void> isConstrainsMatched() async {
    if (isInTime && isLocationMatch) {
      await Future.delayed(
          new Duration(
            seconds: 2,
          ), () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return AttendanceMarkScreen();
        }));
      });
    } else if (!isInTime) {
      Toast.show("Sorry..!, your are exteeded college Time", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.red,
          backgroundColor: Colors.yellow);
    } else if (!isLocationMatch) {
      Toast.show(
          "Sorry..!, Your location not matched with college location", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.red,
          backgroundColor: Colors.yellow);
    }
  }

  Future<void> sendData() async {
    print('in sendData');
    Dio dio = new Dio();
    dio.post("http://www.flutterant.com/alert_me/conn.php", data: {
      "email": "test@gmail.com",
      "name1": "testing",
      "time": "12:00",
      "date1": "set-20-2020",
      "status": true
    }).then((response) {
      print("responser is ${response.data[0]}");
      print("responser is ${response.data}");
      if (response.statusCode == 200) {
        var data = json.decode(response.data);
        print("data is ${data['message']}");
      }
    });
  }
}
