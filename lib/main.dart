import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/dashboard/admin_dashboard.dart';
import 'package:project2/dashboard/customer_home.dart';
import 'package:project2/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Color(0xffFAE072),
      home: LandingPage(),
      theme: ThemeData(
        canvasColor: Colors.transparent,
      ),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/admin_dashboard': (BuildContext context) => new AdminDashBoard(),
        '/customer_home': (BuildContext context) => new CustomerHome(),
        '/login': (BuildContext context) => new LoginPage(),
      },
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
 // final storage = FlutterSecureStorage();
  NetworkHandler networkHandler = NetworkHandler();

  @override
  void initState() {
    startApp();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xff102733)),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'To',
                    style: TextStyle(
                        fontSize: 45,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    'ks',
                    style: TextStyle(
                        fontSize: 45,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffFCCD00)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  startApp() async {
    Timer(Duration(seconds: 1), () {
      checkUser();
    });
  }

  checkUser() async {
    // String token = await storage.read(key: "token");
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var authToken = _prefs.getString("name");
    if (authToken == "ADMIN") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminDashBoard()),
          (Route<dynamic> route) => false);
    } else if (authToken == "CUSTOMER") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CustomerHome()),
          (Route<dynamic> route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }
}
