import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/dashboard/admin_dashboard.dart';
import 'package:project2/dashboard/customer_dashboard.dart';
import 'package:project2/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1)),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: LandingPage(),
            debugShowCheckedModeBanner: false,
            routes: <String, WidgetBuilder>{
              '/admin_dashboard': (BuildContext context) =>
                  new AdminDashBoard(),
              '/customer_dashboard': (BuildContext context) =>
                  new CustomerDashBoard(),
              '/login': (BuildContext context) => new LoginPage(),
            },
          );
        } else {
          //return LandingPage();
          // Loading is done, return the app:
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LandingPage(),
          );
        }
      },
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final storage = FlutterSecureStorage();
  NetworkHandler networkHandler = NetworkHandler();

  // void _tryToAuthenticate() async {
  //   String token = await storage.read(key: 'token');
  //   Provider.of<Auth>(context, listen: false).attempt(token: token);
  // }

  @override
  void initState() {
    startApp();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        child: Stack(
          children: [
            Center(
              child: Text(
                'toks',
                style: TextStyle(
                    fontSize: 45,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900]),
              ),
            ),
          ],
        ),
      )),
    );
  }

  startApp() {
    Timer(Duration(seconds: 2), () {
      checkToken();
    });
  }

  checkToken() async {
    String token = await storage.read(key: "token");
    if (token.isNotEmpty) {
      checkUserType();
    } else {
      await Future.delayed(Duration(seconds: 3));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  void checkUserType() async {
    String userType = await storage.read(key: "name");

    if (userType != "ADMIN") {
     
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CustomerDashBoard()),
          (Route<dynamic> route) => false);
    } else {
     
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminDashBoard()),
          (Route<dynamic> route) => false);
    }
  }
}
