import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:project2/toks_model/person.dart';
import 'package:project2/toks_model/user.dart';

import 'package:project2/utils/userHandler.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';

import 'package:project2/shimmer_objects/shimmer_list.dart';

class WidgetReportList extends StatefulWidget {
  @override
  _WidgetReportListState createState() => _WidgetReportListState();
}

class _WidgetReportListState extends State<WidgetReportList> {
  FlutterSecureStorage storage = new FlutterSecureStorage();

  UserDialog userDialog;
  User userModel;

  _fetchData() async {
    String token = await storage.read(key: "token");

    http.Response response = await http.get(
      Uri.parse(
          "http://toks.herokuapp.com/api/user/get-all-profiles-np/CUSTOMER"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-type": "application/json",
      },
    );
//       var jsonResponse = json.decode(response.body);
// setState(() {
//    userModel = User.fromJson(jsonResponse["responseData"]);
//    print(userModel);
//         });
    var jsonData = json.decode(response.body) as Map<String, dynamic>;
    return jsonData;
  }

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _fetchData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            // Map<String, dynamic> data = jsonDecode(snapshot.data['data']);
            // new Map<String, dynamic>.from(snapshot.data);
            print(snapshot.data);
            // return Text(snapshot.data['firstName']);
            // List<User> datum = snapshot.data;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  // User user = datum[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // profilePic,
                      CircleAvatar(
                        radius: 13,
                        backgroundImage: snapshot.data['profilePhoto'] != null
                            ? NetworkImage(snapshot.data['profilePhoto'])
                            : AssetImage("asset/imageicon.png"),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${snapshot.data['firstName']}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${snapshot.data['emailAddress']}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${snapshot.data['phoneNumber']}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      IconButton(
                          icon: Icon(Icons.person_add_disabled_sharp),
                          tooltip: 'Disable user',
                          onPressed: () {
                            userDialog.handleUserDialog(context,
                                "This user will temporarily be inactive", () {
                              //callingDisableAPI();
                              Navigator.of(context).pop();
                            }, () {
                              Navigator.of(context).pop();
                            });
                          }),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        tooltip: 'Delete user',
                        onPressed: () => userDialog.handleUserDialog(
                          context,
                          "Are you sure you wants to delete? you can't undo the action",
                          () {
                            //deletingUserAPI();
                            Navigator.of(context).pop();
                          },
                          () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          } else if (snapshot.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("${snapshot.error}"),
              ),
            );
          }
          return ShimmerList();
        },
      ),
    );
  }
}
