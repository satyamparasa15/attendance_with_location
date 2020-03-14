import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        isAttendanceMarked();
       // getUserLocation();
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
                'Mark Attendance',
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
      onPressed: () {},
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
                'Show Attendance',
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
      if (distanceInMeters < 10) {
        isLocationMatch = true;
      }
      DateTime now = new DateTime.now();
      DateTime before = new DateTime(now.year, now.month, now.day, 15, 27, 0);
      DateTime after = DateTime.now();
      isInTime = before.isBefore(after);
      print("time checking ..${before.isBefore(after)}");
      print("Time differnces ${before.difference(after).inSeconds}");
      await Future.delayed(Duration(
        seconds: 1
      ), (){
        getAddressLine(location);
      });

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
print("isLOcation $isLocationMatch");
    if (isInTime && isLocationMatch) {
      await Future.delayed(
          new Duration(
            seconds: 2,
          ), () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return AttendanceMarkScreen();
        }));
      });
    } else if (isInTime) {
      print('in if else....');
      Toast.show("Sorry..!, your are exteeded college Time", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM, textColor: Colors.red, backgroundColor: Colors.yellow);
    }else if(isLocationMatch){
      Toast.show("Sorry..!, Your location not matched with college location", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM, textColor: Colors.red, backgroundColor: Colors.yellow);
    }
  }

  void isAttendanceMarked() {
   FirebaseAuth auth = FirebaseAuth.instance;
   DateTime _now = DateTime.now();
   DateTime _start = DateTime(_now.year, _now.month, _now.day, 0, 0);
   DateTime _end = DateTime(_now.year, _now.month, _now.day, 23, 59, 59);

   auth.currentUser().then((user){
     if(user!=null){
       Firestore.instance.collection('attendance').where('email', isEqualTo: user.email)
           .where('date', isGreaterThanOrEqualTo: _start)
           .where('date', isLessThanOrEqualTo: _end)
           .orderBy('date')
           .getDocuments().then((data){
             DateTime dateTime = DateTime.parse(data.documents.first.data['date'].toDate().toString());
             print("datematches ${dateTime.isBefore(DateTime.now())}");
             int diffDays = DateTime.now().difference(dateTime).inDays;
             print("days difference $diffDays");
             print("diffen${DateTime.now().compareTo(dateTime)}");
             bool isSame = (diffDays == 0);
             print("data formate ${DateTime.parse(data.documents.first.data['date'].toDate().toString())
             }");
         print("data is----- ${data.documents.first.data['date']}");
       });
     }
   });

  }
}
