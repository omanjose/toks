import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/dashboard/admin_dashboard.dart';
import 'package:project2/dashboard/customer_home.dart';
import 'package:project2/password_recovery.dart';
import 'package:project2/signup.dart';
import 'package:project2/toks_model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  NetworkHandler networkHandler = NetworkHandler();

  User userModel = User();
  bool validate = false;

  var userPic, fname, lname, email, userType, name = '';
  final emailCtrl = TextEditingController();

  final passwordCtrl = TextEditingController();
  final passwordRecoveryText = TextEditingController();
  final formKey = GlobalKey<FormState>();
  FocusNode myFocusNode = new FocusNode();
  FocusNode myFocusNode2 = new FocusNode();

  bool _isObscure = true;

  _nextFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  String _validateInput(String value) {
    if (value.trim().isEmpty) {
      return 'Field is required!';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();

    super.dispose();
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
                'Authenticating user...',
                style: TextStyle(fontSize: 12, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isLoading = false;
  showInfo() {
    return CupertinoActionSheet(
      title: Center(
        child: Row(
          children: <Widget>[
            Text(
              "To",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ),
            Text(
              "ks",
              style: TextStyle(
                  color: Color(0xffFCCD00),
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            )
          ],
        ),
      ),
      message: Text("Network Error!", style: TextStyle(fontSize: 15)),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text("Check your network connection",
              style: TextStyle(fontSize: 13)),
          isDestructiveAction: true,
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _loginButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () async {
                submitLogin();
              },
              child: Text(
                'Login',
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

  submitLogin() async {
    if (!formKey.currentState.validate()) {
      return;
    }
    formKey.currentState.validate();
    formKey.currentState.save();
    if (await ConnectivityWrapper.instance.isConnected) {
      showAlertDialog();
      SharedPreferences _prefs = await SharedPreferences.getInstance();

      print('Data connection is available.');
      _prefs.setString("password", emailCtrl.text);
      Map<String, String> data = {
        "emailAddress": emailCtrl.text,
        "password": passwordCtrl.text,
      };

      var response = await networkHandler
          .post("/api/user/login", data)
          .timeout(Duration(seconds: 360), onTimeout: () {
        _showSnackBar(
            "Network timed out!", Colors.red[900], Icons.network_check);
        Navigator.pop(context);

        throw TimeoutException(
            'The connection has timed out, please try again');
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> output = json.decode(response.body);
        var content = output["token"];
        print(output["token"]);
        print(content);
        _prefs.setString("storage", content);

        var userResponse = await networkHandler
            .get("/api/user/get-current-user-details")
            .timeout(Duration(seconds: 240), onTimeout: () {
          Navigator.pop(context);
          _showSnackBar("The connection timed out!", Colors.red[900],
              Icons.network_check);
          throw TimeoutException("The connection timed out, couldn't get user");
        });
        var data = json.decode(userResponse.body);
        print(data);
        final responseData = data['responseData'];

        //return User.fromJson(jsonResponse['responseData']);

        var role = responseData["role"];
        var name = role['name'];
        print(name);

        _prefs.setString("name", name);
        print("logging in");

        if (name == "CUSTOMER") {
          print("the user  is " + name);
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => CustomerHome()),
              (route) => false);
        } else if (name == "ADMIN") {
          print("the user  is  " + name);
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminDashBoard()),
              (route) => false);
        } else {
          print('Error! User not defined');
        }

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          validate = false;
          isLoading = false;
          _showSnackBar("Login failed!", Colors.red[900], Icons.error);
          Navigator.pop(context);
        });
      }
    } else {
      print("No internet connection");
      //showInfo();
      _showSnackBar(
          "No network connection", Colors.red[900], Icons.network_check);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: Color(0xff102733)),
              //child: Image.asset("asset/background.png"),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FittedBox(
                              child: Text(
                                "To",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                "ks",
                                style: TextStyle(
                                    color: Color(0xffFFA700),
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 30),
                        FittedBox(
                          child: Text(
                            "Welcome!",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 5),
                        FittedBox(
                          child: Text(
                            "Our mission is to provide you advanced xxx xxxxxxx services!",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          alignment: Alignment(1.0, 0.0),
                          child: GestureDetector(
                            onTap: () async {
                              if (await ConnectivityWrapper
                                  .instance.isConnected) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUpPage()));
                              } else {
                                _showSnackBar("No network connection!",
                                    Colors.red[900], Icons.network_check);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FittedBox(
                                  child: Text(
                                    "Get Started now!",
                                    style: TextStyle(
                                        color: Colors.amber, fontSize: 17),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.amber,
                                )
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                        //email field
                        TextFormField(
                          focusNode: myFocusNode,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail, color: Colors.black),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                                color: myFocusNode.hasFocus
                                    ? Colors.black
                                    : Colors.grey[700]),
                            fillColor: Colors.white70,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.amber, width: 1.0)),
                            enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.black)),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: _validateInput,
                          onFieldSubmitted: (String value) {
                            _nextFocus(myFocusNode2);
                          },
                          keyboardType: TextInputType.emailAddress,
                          controller: emailCtrl,
                        ),
                        SizedBox(height: 10),

                        // password field
                        TextFormField(
                          focusNode: myFocusNode2,
                          onFieldSubmitted: (String value) {
                            submitLogin();
                          },
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.visiblePassword,
                          controller: passwordCtrl,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: myFocusNode2.hasFocus
                                    ? Colors.black
                                    : Colors.grey[700]),
                            fillColor: Colors.white70,
                            filled: true,
                            prefixIcon: Icon(Icons.lock, color: Colors.black),
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.amber, width: 1.0)),
                            enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.black)),
                          ),
                          obscureText: _isObscure,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Password is required!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        Container(
                          alignment: Alignment(1.0, 0.0),
                          child: GestureDetector(
                            onTap: () async {
                              if (await ConnectivityWrapper
                                  .instance.isConnected) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PasswordRecovery()));
                              } else {
                                _showSnackBar("No network connection",
                                    Colors.red[900], Icons.error);
                              }
                            },
                            child: Text(
                              "Recover password",
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 13),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        _loginButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: _onBackButton,
    );
  }

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

  Future<bool> _onBackButton() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
    return Future.value(false);
  }
}
