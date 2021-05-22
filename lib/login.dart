import 'dart:async';
import 'package:achievement_view/achievement_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/dashboard/admin_dashboard.dart';
import 'package:project2/signup.dart';
import 'package:project2/toks_model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard/customer_dashboard.dart';
import 'package:achievement_view/achievement_view.dart';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  NetworkHandler networkHandler = NetworkHandler();
  User user;
  bool validate = false;
  final storage = new FlutterSecureStorage();
  var userPic, fname, lname, email, userType, name = '';
  final emailCtrl = TextEditingController();

  final passwordCtrl = TextEditingController();
  final passwordRecoveryText = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //String _userEmail, _userPassword;

  bool _isObscure = true;

  // checkExistingLogin() async {
  //   String token = await storage.read(key: "token");

  //   if (token != null) {
  //     checkUserType();
  //   } else {
  //     return null;
  //   }
  // }

  // void checkUserType() async {
  //   String userType = await storage.read(key: "name");
  //   if (userType != "CUSTOMER") {
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => AdminDashBoard()),
  //         (route) => false);
  //   } else {
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => CustomerDashBoard()),
  //         (route) => false);
  //   }
  // }

  // void _tryToAuthenticate() async {
  //   String token = await storage.read(key: 'token');
  //   Provider.of<Auth>(context, listen: false).attempt(token: token);
  // }

  @override
  void initState() {
    // checkExistingLogin();

    super.initState();
  }

  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();

    super.dispose();
  }

  bool isLoading = false;

  Widget _loginButton() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState.validate()) {
                    return;
                  }
                  formKey.currentState.validate();
                  formKey.currentState.save();
                  setState(() {
                    isLoading = true;
                  });

                  submitLogin();
                },
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                )),
          ),
        ),
      ],
    );
  }

  submitLogin() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    progressDialog.show();

    var listener =
        DataConnectionChecker().onStatusChange.listen((status) async {
      switch (status) {
        case DataConnectionStatus.connected:
          print('Data connection is available.');

          Map<String, String> data = {
            "emailAddress": emailCtrl.text,
            "password": passwordCtrl.text,
          };
          var response = await networkHandler
              .post("/api/user/login", data)
              .timeout(Duration(seconds: 360), onTimeout: () {
            show(
                context,
                "Poor network connection",
                'The connection has timed out, please try again!',
                Icon(Icons.restore));
            progressDialog.dismiss();
            Navigator.pop(context);

            throw TimeoutException(
                'The connection has timed out, please try again');
          });

          if (response.statusCode == 200 || response.statusCode == 201) {
            Map<String, dynamic> output = json.decode(response.body);
            print(output["token"]);
            await storage.write(key: "token", value: output["token"]);
            var userResponse = await networkHandler
                .getUserDetails("/api/user/get-current-user-details")
                .timeout(Duration(seconds: 120), onTimeout: () {
              progressDialog.dismiss();
              Navigator.pop(context);
              show(context, "Poor network connection",
                  "The connection timed out, retry", Icon(Icons.restore));
              throw TimeoutException(
                  "The connection timed out, couldn't get user");
            });
            var data = jsonDecode(userResponse.body);
            print(data);
            var responseData = data["responseData"];
            print(responseData);
            var role = responseData["role"];
            print(role);
            name = role["name"];
            print(name);
            _prefs.setString("name", name);
            var firstName = responseData["firstName"];
            print(firstName);
            String initials = firstName.substring(0, 1).toUpperCase();
            _prefs.setString("initials", initials);
            _prefs.setString("fname", firstName);
            var lastName = responseData["lastName"];
            print(lastName);
            _prefs.setString("lname", lastName);
            var emailAddress = responseData["emailAddress"];
            print(emailAddress);
            _prefs.setString("email", emailAddress);
            var profilePhotoUrl = responseData["profilePhotoUrl"];
            //decoding the byte string to image, gives error

            // prefs.setInt('userIdKey', user['user_id'] ?? 0);

            _prefs.setString("decodedPic", (profilePhotoUrl) ?? '');

            //converting asset image to string

            print(initials + "from initials");
            if (name == "CUSTOMER") {
              print("the user  is " + name);

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerDashBoard()),
                  (route) => false);
            } else {
              print("the user  is not " + name);

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashBoard()),
                  (route) => false);
            }

            setState(() {
              isLoading = false;
              progressDialog.dismiss();
            });
          } else {
            setState(() {
              validate = false;
              isLoading = false;
              progressDialog.dismiss();
              Navigator.pop(context);
              show(context, "Failed", "Failed to login", Icon(Icons.error));
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

  ArsProgressDialog progressDialog;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
        key: _scaffoldKey,
        body: SafeArea(
          child: Container(
            height: size.height,
            child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      // flex: 1,
                      child: Container(
                        // alignment: Alignment(0.0, 1.0),
                        height: 270,
                        width: size.width,
                        decoration: BoxDecoration(
                          //borderRadius: BorderRadius.only(
                          // topLeft: Radius.circular(15),
                          // topRight: Radius.circular(15)),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage("asset/tokspic.jpg")),
                        ),
                        child: Center(
                          // alignment: Alignment.center,
                          child: Text(
                            'Toks',
                            style: GoogleFonts.lato(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      // flex: 1,
                      child: Container(
                        color: Colors.black,
                        alignment: Alignment.bottomCenter,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15)),
                          ),
                          child: ListView(
                            children: [
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: TextFormField(
                                  // style: TextStyle(color: Colors.grey),
                                  decoration: InputDecoration(
                                      suffixIcon: Icon(Icons.mail),
                                      alignLabelWithHint: true,
                                      hintText: 'you@example.com',
                                      labelText: 'Email',
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey[700],
                                              width: 1.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blue[700],
                                              width: 1.0))),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) =>
                                      EmailValidator.validate(value)
                                          ? null
                                          : "Invalid Email Address",
                                  // onSaved: (value) {
                                  //   _userEmail = value;
                                  // },
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailCtrl,
                                ),
                              ),

                              //SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: TextFormField(
                                  //style: TextStyle(color: Colors.grey),
                                  maxLength: 35,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: passwordCtrl,
                                  decoration: InputDecoration(
                                      // prefixIcon:Icon(Icons.lock),
                                      alignLabelWithHint: true,
                                      hintText: 'password',
                                      labelText: 'Password',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isObscure
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isObscure = !_isObscure;
                                          });
                                        },
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey[700],
                                              width: 1.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blue, width: 1.0))),
                                  obscureText: _isObscure,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Password is required!';
                                    }
                                    return null;
                                  },
                                  // onSaved: (value) {
                                  //   _userPassword = value;
                                  // },
                                ),
                              ),
                              SizedBox(height: 3.0),
                              Container(
                                alignment: Alignment(1.0, 0.0),
                                padding: EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () => passwordRecovering(context),
                                  child: Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                              SizedBox(height: 7),
                              _loginButton(),
                              SizedBox(height: 5),
                              Center(
                                child: Text(
                                  'Don\'t have an account?',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              //SizedBox(height: 5),
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignUpPage()));
                                  },
                                  child: Text(
                                    'Create account',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
      onWillPop: _onBackButton,
    );
  }

  Future<bool> _onBackButton() {
    return Future.value(false);
  }

  passwordRecovering(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close, color: Colors.black),
                      // backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: TextFormField(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: _recoverEmailField(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _submitPasswordReocery(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
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

  Widget _recoverEmailField() {
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

  _submitPasswordReocery() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState.validate()) {
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
