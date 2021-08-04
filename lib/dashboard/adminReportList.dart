import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:project2/toks_model/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:project2/shimmer_objects/shimmer_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminReportList extends StatefulWidget {
  @override
  _AdminReportListState createState() => _AdminReportListState();
}

class _AdminReportListState extends State<AdminReportList> {

  User userModel = new User();

  Future<List<User>> _fetchData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    //String token = await storage.read(key: "token");
    String token = _prefs.getString("storage");
    http.Response response = await http.get(
      Uri.parse("http://toks.herokuapp.com/api/user/get-all-profiles-np/ADMIN"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-type": "application/json",
      },
    );
    final parsed = json.decode(response.body);
    final parsedRes = parsed['responseData'].cast<Map<String, dynamic>>();
    return parsedRes.map<User>((item) => User.fromJson(item)).toList();
  }

  @override
  void initState() {
    super.initState();

    _fetchData();
  }
final refreshKey = GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.white,
      backgroundColor: Colors.green[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Return to previous screen',
        ),
        backgroundColor: Color(0xff102733),
        elevation: 0,
        title: Text("Administrators", style: TextStyle(fontSize: 14)),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff102733),
        ),
        child: RefreshIndicator(
          onRefresh: ()=> Future.sync(() => _fetchData()),
          key: refreshKey,
          child: FutureBuilder<List<User>>(
            future: _fetchData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundImage:
                                  snapshot.data[index].profilePhoto != null
                                      ? Image.network(
                                          snapshot.data[index].profilePhoto)
                                      : AssetImage("asset/imageicon.png"),
                            ),
                            title: Text(
                                "${snapshot.data[index].firstName}" +
                                    " " +
                                    "${snapshot.data[index].lastName}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    "${snapshot.data[index].phoneNumber}\n ${snapshot.data[index].role.name}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(fontSize: 15),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 1.0,
                                height: 1.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    style: flatButtonStyle,
                                    onPressed: () {

                                      handleUserDialog(context,
                                          "You are about leaving this page", () {
                                        //viewUserByIdAPI();
                                        Navigator.of(context).pop();
                                      }, () {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Icon(Icons.person,
                                            color: Colors.amber, size: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Text('View',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    style: flatButtonStyle,
                                    onPressed: () {
                                      // cardB.currentState?.expand();
                                      handleUserDialog(context,
                                          "This user will temporarily be inactive",
                                          () {
                                        //callingDisableAPI();
                                        Navigator.of(context).pop();
                                      }, () {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Icon(Icons.policy_outlined,
                                            color: Colors.amber, size: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Text('Disable',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    style: flatButtonStyle,
                                    onPressed: () {
                                      // cardA.currentState?.toggleExpansion();
                                      handleUserDialog(context,
                                          "Are you sure you wants to delete? you can't undo the action",
                                          () {
                                        //deletingUserAPI();
                                        Navigator.of(context).pop();
                                      }, () {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        // Icon(Icons.swap_vert),
                                        Icon(Icons.delete,
                                            color: Colors.amber, size: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Text('Delete',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.error != null) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(color: Color(0xff102733)),
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                                                    AdminReportList())).then((context) {
                                          _fetchData();
                                        });
                                      },
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return ShimmerList();
            },
          ),
        ),
      ),
    );
  }

 

  //popup for user interaction on the expandibleTile
  handleUserDialog(
      BuildContext context, String bodyText, Function yes, Function cancel) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (context, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            height: 300,
            
            child: SizedBox.expand(
              child: CupertinoAlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "TOKS",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        bodyText,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => yes,
                            child: Text(
                              "Yes",
                              style: TextStyle(fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green[900],
                              onPrimary: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => cancel,
                            child: Text(
                              "Cancel",
                              style: TextStyle(fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue[900],
                              onPrimary: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  // Multipurpose snackBar
  void _showSnackBar(String message, Color color, IconData icon){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          content: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Icon(icon,color: Colors.white, size: 14),
            SizedBox(width: 15),
            Expanded(
              child: Text(message,style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),),
          ]),
          duration: const Duration(seconds: 3),));
  }
}
