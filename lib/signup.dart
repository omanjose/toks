import 'dart:async';
import 'dart:convert';
import 'package:achievement_view/achievement_widget.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/login.dart';
import 'package:achievement_view/achievement_view.dart';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  NetworkHandler networkHandler = NetworkHandler();
  bool validate = true;
  final storage = new FlutterSecureStorage();
  File _imageFile;
  final picker = ImagePicker();
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool circular = false;

  //pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
        show(context, "Photo upload", "No image was selected",
            Icon(Icons.info_outline_sharp));
      }
    });
  }

  //crop image
  Future<void> cropImage() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blueGrey,
            toolbarWidgetColor: Colors.white,
            toolbarTitle: 'Crop',
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          title: 'Crop',
          hidesNavigationBar: false,
        ));
    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
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

  ArsProgressDialog progressDialog;
  @override
  Widget build(BuildContext context) {
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Colors.black.withOpacity(0.5),
        //backgroundColor: Colors.blue[900],
        dismissable: false,
        loadingWidget: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          width: 220,
          height: 60,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                CupertinoActivityIndicator(
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text('Registering...',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ));
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Register'),
      // ),
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 14, bottom: 14, left: 10),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
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
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.18,
                      ),
                      Container(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                              letterSpacing: 3,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                  ),
                  child: Center(
                      child: InkWell(
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: _imageFile == null
                          ? AssetImage("asset/imageicon.png")
                          : FileImage(File(_imageFile.path)),
                    ),
                    onTap: () => takeShot(context),
                  )),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      //borderRadius: BorderRadius.only(
                      //topLeft: Radius.circular(15),
                      // bottomLeft: Radius.circular(15),
                      // bottomRight: Radius.circular(15)),
                      ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(children: [
                      SizedBox(height: 3),
                      _firstName(),
                      SizedBox(height: 3),
                      _lastName(),
                      SizedBox(height: 3),
                      _phoneNum(),
                      SizedBox(height: 3),
                      _buildUserEmail(),
                      SizedBox(height: 3),
                      _buildPassword(),
                      SizedBox(height: 3),
                      _buildConfirmPassword(),
                    ]),
                  ),
                ),
                SizedBox(height: 10),
                _registerButton(),
                SizedBox(height: 10),
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
                        color: Colors.blue[900],
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

// Another loader
  void dialogLoader(BuildContext context) {
    showDialog(
      barrierLabel: 'Toks',
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 50,
            width: 220,
            child: Center(
              child: Row(
                children: [
                  CupertinoActivityIndicator(),
                  SizedBox(width: 5),
                  Text('Please wait...'),
                ],
              ),
            ),
          ),
          elevation: 10,
        );
      },
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                elevation: 5,
                // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              )),
        ),
      ],
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
                    Text(
                      "TOKS",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "You need to Accept terms and conditions",
                      style: TextStyle(fontSize: 10, color: Colors.blue[900]),
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
                            "Accept",
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
              color: Colors.white,
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
      // style: TextStyle(color: Colors.grey),

      decoration: InputDecoration(
          prefixIcon: Icon(Icons.person),
          alignLabelWithHint: true,
          hintText: 'First name',
          labelText: 'First name',
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700])),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[700]))),
      textInputAction: TextInputAction.next,
      validator: (value) => value.isEmpty ? 'First name is required' : null,
      // onSaved: (value) {
      //   _userEmail = value;
      // },
      keyboardType: TextInputType.text,
      controller: _firstameController,
    );
  }

  _lastName() {
    return TextFormField(
      // style: TextStyle(color: Colors.grey),
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.person),
          alignLabelWithHint: true,
          hintText: 'Last name',
          labelText: 'Last name',
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700])),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[700]))),
      textInputAction: TextInputAction.next,
      validator: (value) => value.isEmpty ? 'Last is required' : null,
      // onSaved: (value) {
      //   _userEmail = value;
      // },
      keyboardType: TextInputType.text,
      controller: _lastameController,
    );
  }

  _phoneNum() {
    return TextFormField(
      // style: TextStyle(color: Colors.grey),
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone),
          alignLabelWithHint: true,
          hintText: 'Phone number',
          labelText: 'Phone number',
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700])),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[700]))),
      textInputAction: TextInputAction.next,
      validator: (value) => value.isEmpty ? 'Phone number is required' : null,

      keyboardType: TextInputType.phone,
      controller: _phoneController,
    );
  }

  _buildUserEmail() {
    return TextFormField(
      // style: TextStyle(color: Colors.grey),
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail),
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

      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
    );
  }

  _buildPassword() {
    return TextFormField(
      //style: TextStyle(color: Colors.grey),
      maxLength: 35,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.visiblePassword,
      controller: _passwordController,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          alignLabelWithHint: true,
          hintText: 'password',
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
              _isObscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700])),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue))),
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

  _buildConfirmPassword() {
    return TextFormField(
      //style: TextStyle(color: Colors.grey),
      maxLength: 30,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.visiblePassword,
      controller: _confirmPasswordController,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          alignLabelWithHint: true,
          hintText: 'password',
          labelText: 'Password',
          // suffixIcon: IconButton(
          //   icon: Icon(
          //     _isObscure ? Icons.visibility : Icons.visibility_off,
          //     color: Colors.grey,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _isObscure = !_isObscure;
          //     });
          //   },
          // ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700])),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.blue,
          ))),
      obscureText: true,
      validator: (value) {
        if (value.trim().isEmpty) {
          return 'Password is required';
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
          return Container(
            height: MediaQuery.of(context).size.height * 30,
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      icon: Icon(Icons.close),
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
                Text(
                  "Successful",
                  style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[900]),
                ),
                SizedBox(height: 5),
                Text(
                  'Account successfully created with \n ${_emailController.text}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                      Text(
                        "TOKS",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue[900],
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
                              style: TextStyle(fontSize: 11),
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
                              style: TextStyle(fontSize: 11),
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
              color: Colors.white,
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
      textStyleTitle: TextStyle(color: Colors.white54),
      textStyleSubTitle: TextStyle(color: Colors.white),
      alignment: Alignment.topCenter,
      duration: Duration(seconds: 5),
      isCircle: false,
    )..show();
  }

  // ignore: missing_return
  // submitUser() async {
  //   progressDialog.show();

  //   String token = await storage.read(key: "token");
  //   var uri = Uri.parse("http://ktoks.herokuapp.com/api/user/signup");
  //   var request = http.MultipartRequest('PATCH', uri);
  //   Map<String, String> headers = {
  //     // "content-type": "multipart/form-data",
  //     "content-type": "application/json",
  //     "Authorization": "Bearer $token"
  //   };
  //   request.headers.addAll(headers);
  //   request.fields["confirmPassword"] = _confirmPasswordController.text;
  //   request.fields["emailAddress"] = _emailController.text;
  //   request.fields["firstName"] = _firstameController.text;
  //   request.fields["lastName"] = _lastameController.text;
  //   request.fields["password"] = _passwordController.text;
  //   request.fields["phoneNumber"] = _phoneController.text;
  //   request.fields["role"] = fixedrole;
  //   if (_imageFile.path != null) {
  //     request.files.add(
  //         await http.MultipartFile.fromPath('profilePhoto', _imageFile.path));
  //   }
  //   request.send().then(
  //     (response) {
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         show(context, "Successful", "Account registration is successful",
  //             Icon(Icons.notification_important));
  //         progressDialog.dismiss();
  //         Navigator.of(context).pushAndRemoveUntil(
  //             MaterialPageRoute(builder: (context) => LoginPage()),
  //             (route) => false);
  //         return response;
  //       } else {
  //         setState(() {
  //           progressDialog.dismiss();
  //           show(context, "Failed", "Some error occured", Icon(Icons.error));
  //         });

  //         Navigator.of(context).pushAndRemoveUntil(
  //             MaterialPageRoute(builder: (context) => LoginPage()),
  //             (route) => false);
  //       }
  //       return response;
  //     },
  //   );
  // }

  submitUser() async {
    progressDialog.show();

    var listener =
        DataConnectionChecker().onStatusChange.listen((status) async {
      switch (status) {
        case DataConnectionStatus.connected:
          print('Data connection is available.');
          final bytes = _imageFile.readAsBytesSync();
          String _img64 = base64Encode(bytes);
          print("the converted image " + _img64);
          Map<String, String> data = {
            "confirmPassword": _confirmPasswordController.text,
            "emailAddress": _emailController.text,
            "firstName": _firstameController.text,
            "lastName": _lastameController.text,
            "password": _passwordController.text,
            "phoneNumber": _phoneController.text,
            "profilePhotoUrl": _img64,
            "role": fixedrole,
            "securityKey": null,
          };
          var response = await networkHandler
              .post("/api/user/signup", data)
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
            print("Registered successfully!");
            show(context, "Successful", "Registration was successful",
                Icon(Icons.notifications_active_sharp));

            setState(() {
              isLoading = false;
              progressDialog.dismiss();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false);
              successBottomSheet(context);
              return response;
            });
          } else {
            setState(() {
              validate = false;
              isLoading = false;
              progressDialog.dismiss();
              Navigator.pop(context);
              print("failed to register");
              print(response.statusCode.toString());
              print(response.body);
              show(
                  context,
                  "Failed",
                  "Failed to register" + response.statusCode.toString(),
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
}
