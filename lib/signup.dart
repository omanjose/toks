import 'dart:async';
import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  NetworkHandler networkHandler = NetworkHandler();
  bool validate = true;
  File _imageFile;
  final picker = ImagePicker();
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FocusNode myFocusNode1 = new FocusNode();
  FocusNode myFocusNode2 = new FocusNode();
  FocusNode myFocusNode3 = new FocusNode();
  FocusNode myFocusNode4 = new FocusNode();
  FocusNode myFocusNode5 = new FocusNode();
  FocusNode myFocusNode6 = new FocusNode();
  bool circular = false;

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

  //pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
        _showSnackBar(
            "No image is been selected", Colors.red[900], Icons.camera);
      }
    });
  }

  _nextFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  bool isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _firstameController.dispose();
    _lastameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff102733),
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 14, bottom: 14, left: 10),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          //color: Colors.white,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        width: 25,
                        height: 25,
                        child: InkWell(
                          child: Center(
                            child: Text(
                              'X',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      Column(
                        children: [
                          Container(
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                  //letterSpacing: 3,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 25,
                                  color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              'Complete all fields *',
                              style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: InkWell(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: _imageFile == null
                          ? AssetImage("asset/imageicon.png")
                          : FileImage(File(_imageFile.path)),
                    ),
                    onTap: () => takeShot(context),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(children: [
                    SizedBox(height: 8),
                    _firstName(),
                    SizedBox(height: 8),
                    _lastName(),
                    SizedBox(height: 8),
                    _phoneNum(),
                    SizedBox(height: 8),
                    _buildUserEmail(),
                    SizedBox(height: 8),
                    _buildPassword(),
                    SizedBox(height: 8),
                    _buildConfirmPassword(),
                    SizedBox(height: 10),
                    _registerButton(),
                  ]),
                ),
                SizedBox(height: 15),
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Already have an account',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String fixedrole = "CUSTOMER";
  final _emailController = TextEditingController();
  final _firstameController = TextEditingController();
  final _lastameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _registerButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  circular = true;
                });
                if (_imageFile == null && !_formKey.currentState.validate()) {
                } else {
                  _formKey.currentState.save();
                  _buildDialog(context);
                }
              },
              child: Text(
                'Register',
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

  // Alert dialog
  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Color(0xff102733),
      content: Container(
        decoration: BoxDecoration(color: Color(0xff102733)),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              backgroundColor: Colors.amber,
            ),
            SizedBox(height: 10),
            Container(
              // margin: EdgeInsets.only(left: 5),
              child:
                  Text("Please wait...", style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Terms and conditions dialog
  _buildDialog(BuildContext context) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (context, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 300,
            // child: SizedBox.expand(child: FlutterLogo()),
            child: CupertinoAlertDialog(
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
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
                    SizedBox(height: 12),
                    Text(
                      "I Accept Toks terms and conditions",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900]),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            submitUser();
                            //registering();
                          },
                          child: Text(
                            "Yes ",
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green[700],
                            onPrimary: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red[900],
                            onPrimary: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Color(0xff102733),
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

  onClearPressed() {
    _imageFile = AssetImage('asset/imageicon.png') as File;
    _firstameController.clear();
    _lastameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  _firstName() {
    return TextFormField(
      onFieldSubmitted: (String value) {
        _nextFocus(myFocusNode2);
      },
      focusNode: myFocusNode1,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person, color: Colors.black),
        fillColor: Colors.white70,
        filled: true,
        labelText: 'First name',
        labelStyle: TextStyle(
            color: myFocusNode1.hasFocus ? Colors.black : Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.0)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black)),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) => value.isEmpty ? 'First name is required' : null,
      keyboardType: TextInputType.text,
      controller: _firstameController,
    );
  }

  _lastName() {
    return TextFormField(
      onFieldSubmitted: (String value) {
        _nextFocus(myFocusNode3);
      },
      focusNode: myFocusNode2,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person, color: Colors.black),
        fillColor: Colors.white70,
        filled: true,
        labelText: 'Last name',
        labelStyle: TextStyle(
            color: myFocusNode2.hasFocus ? Colors.black : Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.0)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black)),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) => value.isEmpty ? 'Field is required' : null,
      keyboardType: TextInputType.text,
      controller: _lastameController,
    );
  }

  _phoneNum() {
    return TextFormField(
      onFieldSubmitted: (String value) {
        _nextFocus(myFocusNode4);
      },
      focusNode: myFocusNode3,
      decoration: InputDecoration(
        fillColor: Colors.white70,
        filled: true,
        prefixIcon: Icon(Icons.phone, color: Colors.black),
        labelText: 'Phone number',
        labelStyle: TextStyle(
            color: myFocusNode3.hasFocus ? Colors.black : Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.0)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black)),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) => value.isEmpty ? 'Phone number is required' : null,
      keyboardType: TextInputType.phone,
      controller: _phoneController,
    );
  }

  _buildUserEmail() {
    return TextFormField(
      onFieldSubmitted: (String value) {
        _nextFocus(myFocusNode5);
      },
      focusNode: myFocusNode4,
      decoration: InputDecoration(
        fillColor: Colors.white70,
        filled: true,
        prefixIcon: Icon(Icons.mail, color: Colors.black),
        labelText: 'Email',
        labelStyle: TextStyle(
            color: myFocusNode4.hasFocus ? Colors.black : Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.0)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black)),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) =>
          EmailValidator.validate(value) ? null : "Invalid Email Address",
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
    );
  }

  _buildPassword() {
    return TextFormField(
      focusNode: myFocusNode5,
      onFieldSubmitted: (String value) {
        _nextFocus(myFocusNode6);
      },
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.visiblePassword,
      controller: _passwordController,
      decoration: InputDecoration(
        fillColor: Colors.white70,
        filled: true,
        prefixIcon: Icon(Icons.lock, color: Colors.black),
        alignLabelWithHint: true,
        labelText: 'Password',
        labelStyle: TextStyle(
            color: myFocusNode5.hasFocus ? Colors.black : Colors.grey[700]),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.0)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black)),
      ),
      obscureText: _isObscure,
      validator: (value) {
        if (value.trim().isEmpty) {
          return 'Password is required';
        }
        if (value.trim().length < 6) {
          return 'Passwords must be at least 6 characters in length';
        }

        return null;
      },
    );
  }

  bool _isObscure2 = true;
  _buildConfirmPassword() {
    return TextFormField(
      onFieldSubmitted: (String value) {
        _registerButton();
      },
      focusNode: myFocusNode6,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.visiblePassword,
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        fillColor: Colors.white70,
        filled: true,
        prefixIcon: Icon(Icons.lock, color: Colors.black),
        alignLabelWithHint: true,
        labelText: 'Confirm password',
        labelStyle: TextStyle(
            color: myFocusNode6.hasFocus ? Colors.black : Colors.grey[700]),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure2 ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isObscure2 = !_isObscure2;
            });
          },
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.0)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black)),
      ),
      obscureText: _isObscure2,
      validator: (value) {
        if (value.trim().isEmpty) {
          return 'Password confirmation is required';
        }
        if (value.trim().length < 6) {
          return 'Passwords must be at least 6 characters in length';
        }
        if (value != _passwordController.text) {
          return 'Passwords does not match';
        }
        return null;
      },
    );
  }

  successBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xff102733),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (route) => false);
                        }),
                  ),
                  SizedBox(height: 10),
                  Center(
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
                  SizedBox(height: 10),
                  Text(
                    "Successful",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue[900]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Account successfully created with \n ${_emailController.text}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  takeShot(BuildContext context) {
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
            // child: SizedBox.expand(child: FlutterLogo()),
            child: SizedBox.expand(
              child: CupertinoAlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
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
                      SizedBox(height: 12),
                      Text(
                        "Choose your choice of upload",
                        style: TextStyle(fontSize: 11, color: Colors.blue[900]),
                      ),
                      SizedBox(height: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              pickImage(ImageSource.camera);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Capture with camera",
                              style:
                                  TextStyle(fontSize: 11, color: Colors.amber),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue[700],
                              onPrimary: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              pickImage(ImageSource.gallery);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Select from gallery",
                              style:
                                  TextStyle(fontSize: 11, color: Colors.amber),
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
              color: Color(0xff102733),
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

  submitUser() async {
    
    if (await ConnectivityWrapper.instance.isConnected) {
      showAlertDialog(context);
      final bytes = File(_imageFile.path.toString()).readAsBytesSync();
      String img64 = base64Encode(bytes);
      // print("file name " + img64);
      print("the converted image " + img64);
      Map<String, String> data = {
        "confirmPassword": _confirmPasswordController.text,
        "emailAddress": _emailController.text,
        "firstName": _firstameController.text,
        "lastName": _lastameController.text,
        "password": _passwordController.text,
        "phoneNumber": _phoneController.text,
        "profilePhoto": img64,
      };

      var response = await networkHandler
          .post("/api/user/signup", data)
          .timeout(Duration(seconds: 360), onTimeout: () {
        setState(() {
          _showSnackBar(
              "Connection timed out", Colors.red[900], Icons.network_check);
          Navigator.pop(context);
        });
        throw TimeoutException('The connection has timed out!');
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false);
        successBottomSheet(context);
        });
        
      } else {
        setState(() {
          Navigator.pop(context);
          print("failed to register");
          print(response.statusCode.toString());
          print(response.body);
          _showSnackBar("Registration failed", Colors.red[900], Icons.error);
        });
      }
    } else {
      print("No internet connection");
      _showSnackBar(
          "No network connection", Colors.red[900], Icons.network_check);
      showInfo();
    }
  }
}
