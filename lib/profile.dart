import 'dart:convert';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project2/toks_model/user.dart';
import 'package:project2/utils/userHandler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FlutterSecureStorage storage = FlutterSecureStorage();

  UserDialog usd;
  User userModel = new User();

  getUser() async {
    String token = await storage.read(key: "token");
    progressDialog.show();

    http.Response response = await http.get(
      Uri.parse("http://toks.herokuapp.com/api/user/get-current-user-details"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    // print(jsonResponse);
    setState(() {
      userModel = User.fromJson(jsonResponse.responseData);
      print(userModel);
      //  userModel.fromJson(jsonResponse.responseData);
      // print(userModel);
      progressDialog.dismiss();
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }
  //  @override
  // void dispose() {
  //   super.dispose();
  //   getUser();
  // }

  ArsProgressDialog progressDialog;
  @override
  Widget build(BuildContext context) {
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Colors.blue[900],
        dismissable: false,
        loadingWidget: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          width: 220,
          height: 60,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
                child: Row(
              children: [
                CupertinoActivityIndicator(
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text('Please wait...',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            )),
          ),
        ));
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // background image and bottom contents
          Column(
            children: <Widget>[
              Container(
                height: 200.0,
                decoration: BoxDecoration(
                  //  color: Colors.blue,
                  image: DecorationImage(
                      image: AssetImage('asset/pat4.jpg'), fit: BoxFit.cover),
                ),
                child: Center(
                  child: Text(
                    'Toks' + '\n' + 'Serving your security needs',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 70),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.blueGrey),
                            SizedBox(width: 10),
                            Text(
                              "${userModel.firstName}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 0.8,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.mail, color: Colors.blueGrey),
                          SizedBox(width: 10),
                          Text(
                            "${userModel.emailAddress}",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.blueGrey),
                          SizedBox(width: 10),
                          Text(
                            "${userModel.phoneNumber}",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Any thing else...",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          // Profile image
          Positioned(
            top: 150.0, // (background container size) - (circle height / 2)
            child: Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: userModel.profilePhoto != null
                      ? NetworkImage(userModel.profilePhoto)
                      : AssetImage("asset/imageicon.png"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
