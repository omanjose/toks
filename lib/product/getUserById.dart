import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/toks_model/userByIDModel.dart';

class GetUser extends StatefulWidget {
  @override
  _GetUserState createState() => _GetUserState();
}

class _GetUserState extends State<GetUser> {
  UserById userById;
  NetworkHandler networkHandler;
  var result;

  _fetchUserWithID() async {
    final response =
        await networkHandler.getUserDetails("/api/user/get-profile/id");
    var data = json.decode(response.body);
    var responseData = userByIdFromJson(data);

    setState(() {
      result = userById.responseData;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserWithID();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
