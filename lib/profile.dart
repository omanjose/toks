import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project2/dashboard/admin_dashboard.dart';
import 'package:project2/dashboard/customer_home.dart';
import 'package:project2/toks_model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_controller/networkHandler.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User userModel = User();
  @override
  void initState() {
    super.initState();
    getProfile();
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      content: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Icon(icon, color: Colors.white, size: 14),
        SizedBox(width: 15),
        Expanded(
          child: Text(message,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
        ),
      ]),
      duration: const Duration(seconds: 3),
    ));
  }

  NetworkHandler networkHandler = new NetworkHandler();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  savedData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("fName", userModel.firstName);
    _prefs.setString("lName", userModel.lastName);
    _prefs.setString("email", userModel.emailAddress);
    _prefs.setString("phone", userModel.phoneNumber);
    _prefs.setString("profilePic", userModel.profilePhoto);
  }

  Future<User> getProfile() async {
    final userResponse = await networkHandler
        .get("/api/user/get-current-user-details")
        .timeout(Duration(seconds: 120), onTimeout: () {
      Navigator.pop(context);
      _showSnackBar(
          "The connection timed out!", Colors.red[900], Icons.network_check);
      throw TimeoutException("The connection timed out");
    });
    var data = json.decode(userResponse.body);
    print(data);
    final responseData = data['responseData'];
    setState(() {
      userModel = User.fromJson(responseData);
    });
    savedData();
    return User.fromJson(responseData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () => Future.sync(() => getProfile()),
        child: new FutureBuilder<User>(
          future: getProfile(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                color: Color(0xff102733),
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, left: 8, right: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // background image and bottom contents
                      Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xff102733),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    //color: Colors.white,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  width: 25,
                                  height: 25,
                                  child: InkWell(
                                    child: Center(
                                      child: Text(
                                        'X',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    onTap: () async {
                                      //Navigator.of(context).pop();
                                      SharedPreferences _prefs =
                                          await SharedPreferences.getInstance();
                                      var tempName = _prefs.getString('name');
                                      if (tempName == "CUSTOMER") {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomerHome()));
                                      } else {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AdminDashBoard()));
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    "${snapshot.data.firstName}" +
                                        " " +
                                        "${snapshot.data.lastName}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit_sharp,
                                        color: Colors.amber),
                                    tooltip: 'Edit profile',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditingProfile()),
                                      );
                                    }),
                              ],
                            ),
                          ),
                          Container(
                            height: 200.0,
                            decoration: BoxDecoration(
                              //  color: Colors.blue,

                              image: DecorationImage(
                                  image: AssetImage('asset/tokspic.jpg'),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Color(0xff102733),
                              margin: EdgeInsets.only(top: 70),
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                    child: Row(
                                      children: [
                                        Icon(Icons.person, color: Colors.amber),
                                        SizedBox(width: 20),
                                        Text(
                                          "${snapshot.data.firstName}" +
                                              " " +
                                              "${snapshot.data.lastName}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                    color: Colors.amber,
                                    height: 1,
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Icon(Icons.mail, color: Colors.amber),
                                      SizedBox(width: 20),
                                      Text(
                                        "${snapshot.data.emailAddress}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 1,
                                    color: Colors.amber,
                                    height: 1,
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Icon(Icons.phone, color: Colors.amber),
                                      SizedBox(width: 20),
                                      Text(
                                        "${snapshot.data.phoneNumber}" ??
                                            "not available",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 1,
                                    color: Colors.amber,
                                    height: 1,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Any thing else...",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                  Divider(
                                    thickness: 1,
                                    height: 1,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      // Profile image
                      Positioned(
                        top:
                            150.0, // (background container size) - (circle height / 2)
                        child: Container(
                          height: 100.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff102733),
                            // color: Colors.transparent,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: userModel.profilePhoto != null
                                  ? Image.network(userModel.profilePhoto)
                                  : AssetImage("asset/imageicon.png"),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Container(
                decoration: BoxDecoration(color: Color(0xff102733)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(height: 20),
                        Center(
                          child: Icon(Icons.sentiment_dissatisfied,
                              color: Colors.amber, size: 130),
                        ),
                        SizedBox(height: 50),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'No internet connection',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold),
                            ),
                            Center(
                              child: Text(
                                "Please check your internet connection",
                                style: TextStyle(color: Colors.amber),
                              ),
                            ),
                            SizedBox(height: 10),
                            Center(
                                child: IconButton(
                              icon: Icon(Icons.refresh,
                                  size: 20, color: Colors.amber),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfilePage())).then((context) {
                                  getProfile();
                                });
                              },
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xff102733),
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisSize: MainAxisSize.max,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Colors.amber,
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Text("Please wait...",
                        style: TextStyle(color: Colors.amber)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
