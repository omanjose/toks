import 'dart:async';

import 'package:achievement_view/achievement_view.dart';
import 'package:achievement_view/achievement_widget.dart';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/login.dart';


class PasswordRecovery extends StatefulWidget {
  @override
  _PasswordRecoveryState createState() => _PasswordRecoveryState();
}

class _PasswordRecoveryState extends State<PasswordRecovery> {
  final formKey = GlobalKey<FormState>();
  final passwordRecoveryText = TextEditingController();
  // String _userEmail;
  bool isLoading = false;
  Future<bool> _onBackButton() {
    return Future.value(false);
  }

  NetworkHandler networkHandler;
  ArsProgressDialog progressDialog;
  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
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
    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20, left: 5),
                        child: Container(
                          decoration: BoxDecoration(
                              // color: Colors.grey[200],
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(50)),
                          width: 20,
                          height: 20,
                          child: InkWell(
                            child: Center(
                              child: Text(
                                'X',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: Center(
                          child: Text('Recover your account',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[700])),
                        ),
                      ),
                      _emailField(),
                      SizedBox(height: 10),
                      _submitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: _onBackButton,
    );
  }

  recoveringPassword() async {
   
    setState(() {
      progressDialog.show();
    });
    var listener =
        DataConnectionChecker().onStatusChange.listen((status) async {
      switch (status) {
        case DataConnectionStatus.connected:
          print('Data connection is available.');

          Map<String, String> data = {
            "emailAddress": passwordRecoveryText.text,
          };
          var response = await networkHandler
              .post("/api/user/forgot-password", data)
              .timeout(Duration(seconds: 120), onTimeout: () {
            setState(() {
              show(
                  context,
                  "Poor network connection",
                  'The connection has timed out, please try again!',
                  Icon(Icons.restore));
              progressDialog.dismiss();
              Navigator.pop(context);
            });
            throw TimeoutException(
                'The connection has timed out, please try again');
          });

          if (response.statusCode == 200 || response.statusCode == 201) {
            print(response.statusCode.toString());
            setState(() {
              show(
                  context,
                  "Information",
                  'Check your email for to recover your account!',
                  Icon(Icons.restore));
              progressDialog.dismiss();
              Navigator.pop(context);
            });
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false);
          } else {
            setState(() {
              isLoading = false;
              progressDialog.dismiss();
              print(response.statusCode.toString());
              Navigator.pop(context);
              show(
                  context,
                  "Failed",
                  "Please try again" + response.statusCode.toString(),
                  Icon(Icons.error));
            });
          }
          break;
        case DataConnectionStatus.disconnected:
          setState(() {
            isLoading = false;
            progressDialog.dismiss();
            Navigator.pop(context);
            show(context, "Error!", "Check your network connection.",
                Icon(Icons.error));
            print('Check your network connection.');
          });
          break;
      }
    });
    await Future.delayed(Duration(seconds: 30));
    await listener.cancel();
  }

  Widget _emailField() {
    return TextFormField(
      // style: TextStyle(color: Colors.grey),
      decoration: InputDecoration(
          suffixIcon: Icon(Icons.mail),
          alignLabelWithHint: true,
          hintText: 'you@example.com',
          labelText: 'Email',
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700])),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[700]))),
      textInputAction: TextInputAction.next,
      validator: (value) =>
          EmailValidator.validate(value) ? null : "Invalid Email Address",
      // onSaved: (value) {
      //   _userEmail = value;
      // },
      keyboardType: TextInputType.emailAddress,
      controller: passwordRecoveryText,
    );
  }

  _submitButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () {
                if (!formKey.currentState.validate()) {
                  return;
                }

                formKey.currentState.save();
                recoveringPassword();
                setState(() {
                  progressDialog.show();
                });
              },
              child: Text(
                'Recover password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              )),
        ),
      ],
    );
  }

  void show(BuildContext context, String title, String text, Icon icon) {
    AchievementView(
      context,
      title: title,
      subTitle: text,
      // onTab: _onTabAchievement,
      icon: icon,
      typeAnimationContent: AnimationTypeAchievement.fadeSlideToUp,
      borderRadius: 5.0,
      color: Colors.red[900],
      textStyleTitle: TextStyle(color: Colors.white24),
      textStyleSubTitle: TextStyle(color: Colors.white),
      alignment: Alignment.topCenter,
      duration: Duration(seconds: 5),
      isCircle: false,
    )..show();
  }
}
