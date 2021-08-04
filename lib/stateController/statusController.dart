import 'dart:async';
import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/toks_model/user.dart';

class GetStatusController extends GetxController{

  bool enabled = true;
  String status = "";

  void userStatus() {
    if (enabled == true) {
      status = "Enabled";
    } else {
      status = "Disabled";
    }
  }

  BuildContext context;

  //dialog for snackBar
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
      duration: const Duration(seconds: 4),
    ));
  }

  // Alert dialog
  showAlertDialog() {
    showDialog(
      context:context,
      barrierColor:Color(0xff102733),
      barrierDismissible: false,
      builder: (context)=>
          WillPopScope(
            onWillPop: ()async=>false,
            child: SimpleDialog(
              elevation:0,
              backgroundColor: Color(0xff102733),
              children: [

                Center( child:Text('Authenticating user', style:TextStyle(color:Colors.amber),),),

              ],
            ),
          ),
    );
  }


  User userModel = User();
  NetworkHandler networkHandler = new NetworkHandler();
  enableUserAPI()async{
    if (await ConnectivityWrapper.instance.isConnected){
      showAlertDialog();

      var response = await networkHandler
          .get(
          "/api/user/enable-profile/${userModel.id}") // getting with body is faulty!
          .timeout(Duration(seconds: 360), onTimeout: () {
        _showSnackBar("Network Timed out", Colors.red, Icons.network_check);
        Navigator.pop(context);
        throw TimeoutException(
            'The connection has timed out, please try again');
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = json.decode(response.body);
        var res = data['responseData'];
        print(res);
        // setState(() {
        //   userModel = User.fromJson(response['responseData']);
        //
        // });
        Navigator.of(context).pop();
        _showSnackBar("${userModel.firstName} ${userModel.lastName}'s account enabled", Colors.green[800], Icons.verified_outlined);
        update();
        return User.fromJson(res);

      } else {
        _showSnackBar("No network connection", Colors.red[900],
            Icons.error_outline_sharp);
      }
    }
  }
}