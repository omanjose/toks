import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project2/dashboard/widget_builder.dart';
import 'package:project2/toks_model/user.dart';
import 'package:project2/utils/userHandler.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // final _formKey = GlobalKey<FormFieldState>();
  final searchText = TextEditingController();
  FlutterSecureStorage storage = new FlutterSecureStorage();

  UserDialog userDialog;

  Future<List<User>> _fetchData() async {
    String token = await storage.read(key: "token");

    http.Response response = await http.get(
      Uri.parse(
          "http://toks.herokuapp.com/api/user/get-all-profiles-np/CUSTOMER"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      var userData = json.decode(response.body) as List;
      var listUsers = userData.map((e) => User.fromJson(e)).toList();

      return listUsers;
    } else {
      throw "Unable to retrieve users";
    }
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: WidgetReportList(),
        ),
      ),
    );
  }
}
