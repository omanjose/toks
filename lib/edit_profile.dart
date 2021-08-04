import 'dart:async';
import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/profile.dart';
import 'package:project2/toks_model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditingProfile extends StatefulWidget {
  @override
  _EditingProfileState createState() => _EditingProfileState();
}

class _EditingProfileState extends State<EditingProfile> {
  NetworkHandler networkHandler = new NetworkHandler();
  User userModel = new User();
  final picker = ImagePicker();
  File _imageFile;
  // var txtfName = new TextEditingController();
  var txtfName = new TextEditingController();
  var txtlName = TextEditingController();
  var txtEmail = TextEditingController();
  var txtPhone = TextEditingController();

  FocusNode myFocusNode1 = new FocusNode();
  FocusNode myFocusNode2 = new FocusNode();
  FocusNode myFocusNode3 = new FocusNode();
  FocusNode myFocusNode4 = new FocusNode();

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

  var firstName, lastName, emailAddress, phoneNumber, picture;

  getData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    firstName = _prefs.getString("fName");
    txtfName.value = TextEditingValue(text: firstName.toString());
    lastName = _prefs.getString("lName");
    txtlName.value = TextEditingValue(text: lastName);
    emailAddress = _prefs.getString("email");
    txtEmail.value = TextEditingValue(text: emailAddress);
    phoneNumber = _prefs.getString("phone");
    txtPhone.value = TextEditingValue(text: phoneNumber);
    picture = _prefs.getString("profilePic");
  }

  _nextFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff102733),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios,
                              color: Colors.amber, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          "Edit Account",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: formKey,
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          Center(
                            child: InkWell(
                              child: CircleAvatar(
                                radius: 45,
                                backgroundImage: picture == null
                                    ? AssetImage("asset/imageicon.png")
                                    : FileImage(File(picture.path)),
                              ),
                              onTap: () => takeShot(context),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            onFieldSubmitted: (String value) {
                              _nextFocus(myFocusNode2);
                            },
                            focusNode: myFocusNode1,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.black),
                              fillColor: Colors.white70,
                              filled: true,
                              labelText: 'First name',
                              labelStyle: TextStyle(
                                  color: myFocusNode1.hasFocus
                                      ? Colors.black
                                      : Colors.grey[700]),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.amber, width: 1.0)),
                              enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.black)),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value.isEmpty ? 'First name is required' : null,
                            keyboardType: TextInputType.text,
                            controller: txtfName,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            onFieldSubmitted: (String value) {
                              _nextFocus(myFocusNode3);
                            },
                            focusNode: myFocusNode2,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.black),
                              fillColor: Colors.white70,
                              filled: true,
                              labelText: 'Last name',
                              labelStyle: TextStyle(
                                  color: myFocusNode2.hasFocus
                                      ? Colors.black
                                      : Colors.grey[700]),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.amber, width: 1.0)),
                              enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.black)),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value.isEmpty ? 'Field is required' : null,
                            keyboardType: TextInputType.text,
                            controller: txtlName,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            onFieldSubmitted: (String value) {
                              _nextFocus(myFocusNode4);
                            },
                            focusNode: myFocusNode3,
                            decoration: InputDecoration(
                              fillColor: Colors.white70,
                              filled: true,
                              prefixIcon:
                                  Icon(Icons.phone, color: Colors.black),
                              labelText: 'Phone number',
                              labelStyle: TextStyle(
                                  color: myFocusNode3.hasFocus
                                      ? Colors.black
                                      : Colors.grey[700]),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.amber, width: 1.0)),
                              enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.black)),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) => value.isEmpty
                                ? 'Phone number is required'
                                : null,
                            keyboardType: TextInputType.phone,
                            controller: txtPhone,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            onFieldSubmitted: (String value) {
                              submitChanges();
                            },
                            focusNode: myFocusNode4,
                            decoration: InputDecoration(
                              fillColor: Colors.white70,
                              filled: true,
                              prefixIcon: Icon(Icons.mail, color: Colors.black),
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                  color: myFocusNode4.hasFocus
                                      ? Colors.black
                                      : Colors.grey[700]),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.amber, width: 1.0)),
                              enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.black)),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) => EmailValidator.validate(value)
                                ? null
                                : "Invalid Email Address",
                            keyboardType: TextInputType.emailAddress,
                            controller: txtEmail,
                          ),
                          SizedBox(height: 15),
                          submitButton()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  submitButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () {
                setState(() {});
                if (_imageFile == null && !formKey.currentState.validate()) {
                } else {
                  formKey.currentState.save();
                  submitChanges();
                }
              },
              child: Text(
                'Save',
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

//edited changes function
  submitChanges() async {
    try {
      if (await ConnectivityWrapper.instance.isConnected) {
        showAlertDialog(context);

        final bytes = File(_imageFile.path).readAsBytesSync();
        String img64 = base64Encode(bytes);
        print("file converted pic: " + img64);
        Map<String, String> data = {
          "emailAddress": txtEmail.text,
          "firstName": txtfName.text,
          "lastName": txtlName.text,
          "phoneNumber": txtPhone.text,
          "profilePhoto": img64,
        };
        final response = await networkHandler
            .put("/api/user/edit-profile", data)
            .timeout(Duration(seconds: 120), onTimeout: () {
          setState(() {
            _showSnackBar(
                "Connection timed out", Colors.red[900], Icons.network_check);
            Navigator.pop(context);
          });
          throw TimeoutException('The connection has timed out!');
        });
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pop(context);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ProfilePage()),
              (route) => false);
          _showSnackBar(
              "Changes made successfully!", Colors.green[700], Icons.info);
        }
      } else {
        _showSnackBar("Network error", Colors.red[900], Icons.error);
        Navigator.of(context).pop();
      }
    } catch (error) {
      error.toString();
      Navigator.of(context).pop();
      _showSnackBar(
          error.toString() + " error occurred", Colors.red[900], Icons.error);
    }
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

  //collect picture
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

  onClearPressed() {
    _imageFile = AssetImage('asset/imageicon.png') as File;
    txtfName.clear();
    txtlName.clear();
    txtEmail.clear();
    txtPhone.clear();
  }
}
