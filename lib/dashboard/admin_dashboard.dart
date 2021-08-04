import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/dashboard/settings.dart';

import 'package:project2/product/pagination.dart';
import 'package:project2/toks_model/user.dart';
import '../profile.dart';
import 'search.dart';

class AdminDashBoard extends StatefulWidget {
  @override
  _AdminDashBoardState createState() => _AdminDashBoardState();
}

class _AdminDashBoardState extends State<AdminDashBoard> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  NetworkHandler networkHandler = new NetworkHandler();
  // Multipurpose snackBar
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

  User userModel = User();
  Future <User> getProfile() async {
    final userResponse = await networkHandler
        .get("/api/user/get-current-user-details")
        .timeout(Duration(seconds: 120), onTimeout: () {
      Navigator.pop(context);
      _showSnackBar("The connection timed out!", Colors.red[900], Icons.network_check);
      throw TimeoutException("The connection timed out");
    });
    var data = json.decode(userResponse.body);
    print(data);
    final responseData = data['responseData'];
    setState(() {
      userModel = User.fromJson(responseData);
    });

    return User.fromJson(responseData);
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  Timer timer;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return _dashboardUI();
  }

  _dashboardUI() {
    return Scaffold(
      backgroundColor: Color(0xff102733),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () => Future.sync(() => getProfile()),
        child: FutureBuilder<User>(
            future: getProfile(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Color(0xff102733)),
                      ),
                      SingleChildScrollView(
                        child: Container(
                          // height: MediaQuery.of(context).size.height,
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10.0, left: 5),
                                child: Row(
                                  children: <Widget>[
                                    // Image.asset(
                                    //   "asset/imageicon.png",
                                    //   height: 28,
                                    // ),
                                    // SizedBox(
                                    //   width: 4,
                                    // ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          "To",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25,
                                              fontWeight: FontWeight.w800),
                                        ),
                                        Text(
                                          "ks",
                                          style: TextStyle(
                                              color: Color(0xffFCCD00),
                                              fontSize: 25,
                                              fontWeight: FontWeight.w800),
                                        )
                                      ],
                                    ),
                                    Spacer(),
                                    IconButton(
                                        icon: Icon(Icons.search,
                                            size: 19, color: Colors.white),
                                        onPressed: () {
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) => SettingsPage()));
                                        }),

                                    InkWell(
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundImage: snapshot
                                                    .data.profilePhoto !=
                                                null
                                            ? Image.network(
                                                snapshot.data.profilePhoto)
                                            : AssetImage('asset/imageicon.png'),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SettingsPage()));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 7),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: FittedBox(
                                          child: Text(
                                            'Hello ${snapshot.data.firstName} ${snapshot.data.lastName}!',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: FittedBox(
                                          child: Text(
                                            greeting(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    height: 50,
                                    width: 55,
                                    child: Column(
                                      children: [
                                        Text(
                                            "${DateFormat('EEEE').format(DateTime.now())}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                color: Color(0xff102733))),
                                        Text(
                                            "${DateFormat('dd').format(DateTime.now())}",
                                            style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff102733))),
                                        Text(
                                            "${DateFormat('MMMM').format(DateTime.now())}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                color: Color(0xff102733))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3),
                              FittedBox(
                                child: Text(
                                  "${snapshot.data.emailAddress}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

//Date and time
                              SizedBox(height: 5),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Explore Toks",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),

                              //note

                              SizedBox(height: 2),

                              Divider(
                                  thickness: 2,
                                  height: 2,
                                  color: Color(0xffFAE072)),
                              SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox.fromSize(
                                    size:
                                        Size(60, 60), // button width and height
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.amber, // button color
                                        child: InkWell(
                                          splashColor:
                                              Colors.amber[900], // splash color
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaginationView()));
                                          }, // button pressed
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(Icons.explore_sharp,
                                                  color: Colors.black),
                                              SizedBox(height: 4), // icon
                                              Text(
                                                "Explore", //pagination
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ), // text
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox.fromSize(
                                    size:
                                        Size(60, 60), // button width and height
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.amber, // button color
                                        child: InkWell(
                                          splashColor:
                                              Colors.amber[900], // splash color
                                          onTap: () {
                                            _buildModal();
                                          }, // button pressed
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              // Icon(Icons.verified_user_outlined, color: Colors.black),
                                              Icon(Icons.car_rental,
                                                  color: Colors.black),
                                              SizedBox(height: 4), // icon
                                              Text(
                                                "Add Car",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox.fromSize(
                                    size:
                                        Size(60, 60), // button width and height
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.amber, // button color
                                        child: InkWell(
                                          splashColor:
                                              Colors.amber[900], // splash color
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SearchPage()));
                                          }, // button pressed
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(Icons.search,
                                                  color: Colors.black),
                                              SizedBox(height: 4), // icon
                                              Text(
                                                "Search",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ), // text
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox.fromSize(
                                    size:
                                        Size(60, 60), // button width and height
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.amber, // button color
                                        child: InkWell(
                                          splashColor:
                                              Colors.amber[900], // splash color
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfilePage()));
                                          }, // button pressed
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(Icons.person,
                                                  color: Colors.black),
                                              SizedBox(height: 4), // icon
                                              Text(
                                                "Profile",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ), // text
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Divider(
                                color: Colors.amber,
                                thickness: 2,
                                height: 2,
                              ),
                              SizedBox(height: 10),

                              //  pieChartAnalysis(),  //line chart preferrable
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Admin DashBoard',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 5),
                              Divider(
                                color: Colors.amber,
                                thickness: 1,
                                height: 1,
                              ),

                              // recordWidget(), //monitor this
                              Divider(
                                  thickness: 2,
                                  height: 2,
                                  color: Color(0xffFAE072)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  decoration: BoxDecoration(color: Color(0xff102733)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: SingleChildScrollView(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No Connection',
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
                                                  AdminDashBoard()))
                                      .then((context) {
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
              return Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.amber,
              ));
              // return DashBoardShimmer();
            }),
      ),
    );
  }

  _buildModal(){
   return showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Color(0xff102733),
        context: context, builder: (context){
      return SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Color(0xff102733)),
          height: MediaQuery.of(context).size.height,
          child:
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
              _carType(),
                SizedBox(height: 10),
                _carInfo(),
                SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () { },
                      child: Text(
                        'Post',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.amber,
                        onPrimary: Colors.white,
                        elevation: 5,
                        // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      )),
                ),
              ],
            ),
              ],
            ),
          ),
        ),
      );
    });
  }
  FocusNode myFocusNode1 = new FocusNode();
  FocusNode myFocusNode2 = new FocusNode();

  final txtCar = TextEditingController();
  final txtQty = TextEditingController();
  _nextFocus(FocusNode focusNode){
    FocusScope.of(context).requestFocus(focusNode);
  }
  _carType() {
    return TextFormField(
      onFieldSubmitted: (String value){
        _nextFocus(myFocusNode2);
      },
      focusNode: myFocusNode1,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.note_add_rounded, color: Colors.black),
        fillColor: Colors.white70,
        filled: true,
        labelText: 'New Car',
        labelStyle: TextStyle(
            color: myFocusNode1.hasFocus ? Colors.black : Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.0)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black)),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) => value.isEmpty ? 'First name is required' : null,
      keyboardType: TextInputType.text,
      controller: txtCar,
    );
  }
  _carInfo() {
    return TextFormField(
      onFieldSubmitted: (String value){
        submitRegistration();
      },
      focusNode: myFocusNode2,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.pages, color: Colors.black),
        fillColor: Colors.white70,
        filled: true,
        labelText: 'Car Information',
        labelStyle: TextStyle(
            color: myFocusNode2.hasFocus ? Colors.black : Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.0)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black)),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) => value.isEmpty ? 'Field is required' : null,
      keyboardType: TextInputType.text,
      controller: txtQty,
    );
  }

  //submit car registration
  submitRegistration()async{

  }

// Alert dialog
  showAlertDialog() {
    showDialog(
      context: context,
      barrierColor: Color(0xff102733),
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(
          elevation: 0,
          backgroundColor: Color(0xff102733),
          children: [
            Center(
              child: Text(
                'Please wait...',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
