import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
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
  FocusNode myFocusNode1 = new FocusNode();
  bool isLoading = false;
  Future<bool> _onBackButton() {
    return Future.value(false);
  }

  NetworkHandler networkHandler;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xff102733),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          width: 20,
                          height: 20,
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
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      // SizedBox(height: 10),
                      Container(
                        child: Text('Recover your account',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.amber)),
                      ),
                      SizedBox(height: 15),
                      _emailField(),
                      SizedBox(height: 20),
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

  recoveringPassword() async {
    if (await ConnectivityWrapper.instance.isConnected) {
      showAlertDialog();
      Map<String, String> data = {
        "emailAddress": passwordRecoveryText.text,
      };
      var response = await networkHandler
          .post("/api/user/forgot-password", data)
          .timeout(Duration(seconds: 120), onTimeout: () {
        setState(() {
          Navigator.pop(context);
          _showSnackBar('The connection has timed out, please try again!',
              Colors.red[900], Icons.network_check);
        });
        throw TimeoutException(
            'The connection has timed out, please try again');
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.statusCode.toString());
        setState(() {
          _showSnackBar("Check your email for to recover your account!",
              Colors.green[700], Icons.restore);
        });

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false);
      } else {
        setState(() {
          isLoading = false;

          print(response.statusCode.toString());
          Navigator.pop(context);
          _showSnackBar("Please try again" + response.statusCode.toString(),
              Colors.red[900], Icons.error);
        });
      }
    }
  }

  Widget _emailField() {
    return TextFormField(
      focusNode: myFocusNode1,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail, color: Colors.black),
        alignLabelWithHint: true,
        fillColor: Colors.white70,
        filled: true,
        hintText: 'you@example.com',
        labelText: 'Email',
        labelStyle: TextStyle(
            color: myFocusNode1.hasFocus ? Colors.black : Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.0)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black)),
      ),
      onFieldSubmitted:(value){ _submitButton();},
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

              },
              child: Text(
                'Recover password',
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
    );
  }
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
}
