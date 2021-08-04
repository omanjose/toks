import 'dart:async';
import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/login.dart';
import 'package:project2/toks_model/user.dart';
import 'package:project2/utils/errorPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../edit_profile.dart';
import 'admin_dashboard.dart';
import 'customer_home.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //logout function
  void logout() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove("storage");
    _prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
  }

  User userModel = User();
  NetworkHandler networkHandler = new NetworkHandler();

  Future<User> getProfile() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String token = _prefs.getString("storage");
    final response = await http.get(
        Uri.parse(
            "http://toks.herokuapp.com/api/user/get-current-user-details"),
        headers: {"Authorization": "Bearer $token"});

    final jsonResponse = json.decode(response.body);
    setState(() {
      userModel = User.fromJson(jsonResponse['responseData']);
      //print(userModel.firstName + " " + userModel.emailAddress);
    });
    return User.fromJson(jsonResponse['responseData']);
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  _nextFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  final refKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.amber),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Me',
            style: TextStyle(color: Colors.amber, fontSize: 14),
          ),
          backgroundColor: Color(0xff102733),
          elevation: 0,
        ),
        body: RefreshIndicator(
          key: refKey,
          onRefresh: () => Future.sync(() => getProfile()),
          child: FutureBuilder<User>(
            future: getProfile(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  decoration: BoxDecoration(color: Color(0xff102733)),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView(
                      //shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      children: [
                        Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 10, bottom: 5),
                            child: Row(
                              children: [
                                //profile picture

                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      snapshot.data.profilePhoto != null
                                          ? Image.network(
                                              snapshot.data.profilePhoto)
                                          : AssetImage('asset/imageicon.png'),
                                ),
                                SizedBox(width: 20),
                                FittedBox(
                                  child: Text(
                                    '${snapshot.data.firstName} ${snapshot.data.lastName}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        ListTile(
                          leading: Icon(Icons.lock, color: Colors.amber),
                          title: Text(' Change your password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              )),
                          trailing: Icon(Icons.arrow_forward_ios_sharp,
                              color: Colors.amber, size: 12),
                          onTap: () {
                            bottomCustomSheet();
                          },
                        ),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        ListTile(
                          leading: Icon(Icons.edit, color: Colors.amber),
                          title: Text(' Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              )),
                          trailing: Icon(Icons.arrow_forward_ios_sharp,
                              color: Colors.amber, size: 12),
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditingProfile()));
                          },
                        ),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        Container(
                          height: 20,
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'More',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white),
                          ),
                        ),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        ListTile(
                          leading: Icon(Icons.language, color: Colors.amber),
                          title: Text("Language",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.white)),
                          subtitle: Text("English",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              )),
                          trailing: Icon(Icons.arrow_forward_ios_sharp,
                              size: 12, color: Colors.amber),
                          onTap: () {},
                        ),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        ListTile(
                          leading: Icon(Icons.power_settings_new,
                              color: Colors.amber),
                          title: Text("Logout",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              )),
                          trailing: Icon(Icons.arrow_forward_ios_sharp,
                              size: 12, color: Colors.amber),
                          onTap: () => logout(),
                        ),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        ListTile(
                          leading: Icon(Icons.whatshot, color: Colors.amber),
                          title: Text("FAQ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              )),
                          trailing: Icon(Icons.arrow_forward_ios_sharp,
                              size: 12, color: Colors.amber),
                          onTap: () => {},
                        ),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        ListTile(
                          leading: Icon(Icons.share, color: Colors.amber),
                          title: Text("Share",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              )),
                          trailing: Icon(Icons.arrow_forward_ios_sharp,
                              size: 12, color: Colors.amber),
                          onTap: () => {},
                        ),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        ListTile(
                          leading: Icon(Icons.info_outline_rounded,
                              color: Colors.amber),
                          title: Text("Terms and Conditions",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              )),
                          trailing: Icon(Icons.arrow_forward_ios_sharp,
                              size: 12, color: Colors.amber),
                          onTap: () => {},
                        ),
                        Divider(
                          color: Colors.amber,
                          thickness: 1,
                          height: 1,
                        ),
                        ListTile(
                          leading: Icon(Icons.delete, color: Colors.amber),
                          title: Text("Delete Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              )),
                          trailing: Icon(Icons.arrow_forward_ios_sharp,
                              size: 12, color: Colors.amber),
                          onTap: () => showDeletionDialog(context),
                        ),
                      ],
                    ),
                  )),
                );
              } else if (snapshot.hasError) {
                return SingleChildScrollView(child: ErrorIndicatorPage());
              }
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xff102733),
                ),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.max,
                  children: [
                    CircularProgressIndicator(
                      backgroundColor: Colors.amber,
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Text("Please wait...",
                          style: TextStyle(color: Colors.amber)),
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }

  //implement a bottom sheet modal for changing password!
  bool isObscure = true;
  bool isObscure1 = true;
  bool isObscure2 = true;
  FocusNode myFocusNode1 = new FocusNode();
  FocusNode myFocusNode2 = new FocusNode();
  FocusNode myFocusNode3 = new FocusNode();

  final passwordOld = TextEditingController();
  final passwordNew1 = TextEditingController();
  final passwordNew2 = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool _showSecond = false;
  
  bottomCustomSheet() {
    BottomSheet(
      onClosing: () {},
      builder: (BuildContext context) => AnimatedContainer(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: AnimatedCrossFade(
            firstChild: Container(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height - 200),
//remove constraint and add your widget hierarchy as a child for first view
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                            onPressed: () => setState(() => _showSecond = true),
                            child: Text(
                              "Cancel",
                              style:
                                  TextStyle(fontSize: 11, color: Colors.amber),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue[900],
                              onPrimary: Colors.white,
                            ),
                          ),
                
              ),
            ),
            secondChild: Container(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height / 3),
//remove constraint and add your widget hierarchy as a child for second view
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                            onPressed: () => setState(() => _showSecond = false),
                            child: Text(
                              "Ok",
                              style:
                                  TextStyle(fontSize: 11, color: Colors.amber),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue[900],
                              onPrimary: Colors.white,
                            ),
                          ),
               
              ),
            ),
            crossFadeState: _showSecond
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 400)),
        duration: Duration(milliseconds: 400),
      ),
    );
    // showModalBottomSheet(
    //     context: context,
    //     builder: (_) {
    //       return Container(
    //         height: MediaQuery
    //             .of(context)
    //             .size
    //             .height,
    //         decoration: BoxDecoration(color: Color(0xff102733)),
    //         child: Form(
    //           key: formKey,
    //           child: Column(
    //             children: [
    //               Visibility(
    //                 visible: isVisible,
    //                 child: TextFormField(
    //                   focusNode: myFocusNode1,
    //                   onFieldSubmitted: (String value) {
    //                     // verifyOldPassword();
    //                   },
    //                   textInputAction: TextInputAction.next,
    //                   keyboardType: TextInputType.visiblePassword,
    //                   controller: passwordOld,
    //                   decoration: InputDecoration(
    //                     labelStyle: TextStyle(
    //                         color: myFocusNode1.hasFocus
    //                             ? Colors.black
    //                             : Colors.grey[700]),
    //                     fillColor: Colors.white70,
    //                     filled: true,
    //                     prefixIcon: Icon(Icons.lock, color: Colors.black),
    //                     labelText: 'Old password',
    //                     suffixIcon: IconButton(
    //                       icon: Icon(
    //                         isObscure ? Icons.visibility : Icons.visibility_off,
    //                         color: Colors.black,
    //                       ),
    //                       onPressed: () {
    //                         setState(() {
    //                           isObscure = !isObscure;
    //                         });
    //                       },
    //                     ),
    //                     focusedBorder: OutlineInputBorder(
    //                         borderSide:
    //                         BorderSide(color: Colors.amber, width: 1.0)),
    //                     enabledBorder: UnderlineInputBorder(
    //                         borderRadius: BorderRadius.circular(10.0),
    //                         borderSide: BorderSide(color: Colors.black)),
    //                   ),
    //                   obscureText: isObscure,
    //                   validator: (value) {
    //                     if (value.isEmpty) {
    //                       return 'provide old password';
    //                     }
    //                     return null;
    //                   },
    //                 ),
    //               ),
    //               SizedBox(height: 10),
    //               Visibility(
    //                 visible: isVisible,
    //                 child: _checkOldPasswordButton(),
    //               ),

    //               Visibility(
    //                 visible: otherVisible,
    //                 child: TextFormField(
    //                   focusNode: myFocusNode2,
    //                   onFieldSubmitted: (String value) {
    //                     _nextFocus(myFocusNode3);
    //                   },
    //                   textInputAction: TextInputAction.next,
    //                   keyboardType: TextInputType.visiblePassword,
    //                   controller: passwordNew1,
    //                   decoration: InputDecoration(
    //                     labelStyle: TextStyle(
    //                         color: myFocusNode2.hasFocus
    //                             ? Colors.black
    //                             : Colors.grey[700]),
    //                     fillColor: Colors.white70,
    //                     filled: true,
    //                     prefixIcon: Icon(Icons.lock, color: Colors.black),
    //                     labelText: 'Old password',
    //                     suffixIcon: IconButton(
    //                       icon: Icon(
    //                         isObscure ? Icons.visibility : Icons.visibility_off,
    //                         color: Colors.black,
    //                       ),
    //                       onPressed: () {
    //                         setState(() {
    //                           isObscure1 = !isObscure1;
    //                         });
    //                       },
    //                     ),
    //                     focusedBorder: OutlineInputBorder(
    //                         borderSide:
    //                         BorderSide(color: Colors.amber, width: 1.0)),
    //                     enabledBorder: UnderlineInputBorder(
    //                         borderRadius: BorderRadius.circular(10.0),
    //                         borderSide: BorderSide(color: Colors.black)),
    //                   ),
    //                   obscureText: isObscure1,
    //                   validator: (value) {
    //                     if (value.isEmpty) {
    //                       return 'Password is required!';
    //                     }
    //                     return null;
    //                   },
    //                 ),
    //               ),
    //               SizedBox(height: 10),
    //               Visibility(
    //                 visible: otherVisible,
    //                 child: TextFormField(
    //                   focusNode: myFocusNode3,
    //                   onFieldSubmitted: (String value) {
    //                     _checkButton();
    //                   },
    //                   textInputAction: TextInputAction.next,
    //                   keyboardType: TextInputType.visiblePassword,
    //                   controller: passwordNew2,
    //                   decoration: InputDecoration(
    //                     labelStyle: TextStyle(
    //                         color: myFocusNode3.hasFocus
    //                             ? Colors.black
    //                             : Colors.grey[700]),
    //                     fillColor: Colors.white70,
    //                     filled: true,
    //                     prefixIcon: Icon(Icons.lock, color: Colors.black),
    //                     labelText: 'Old password',
    //                     suffixIcon: IconButton(
    //                       icon: Icon(
    //                         isObscure ? Icons.visibility : Icons.visibility_off,
    //                         color: Colors.black,
    //                       ),
    //                       onPressed: () {
    //                         setState(() {
    //                           isObscure2 = !isObscure2;
    //                         });
    //                       },
    //                     ),
    //                     focusedBorder: OutlineInputBorder(
    //                         borderSide:
    //                         BorderSide(color: Colors.amber, width: 1.0)),
    //                     enabledBorder: UnderlineInputBorder(
    //                         borderRadius: BorderRadius.circular(10.0),
    //                         borderSide: BorderSide(color: Colors.black)),
    //                   ),
    //                   obscureText: isObscure2,
    //                   validator: (value) {
    //                     if (value.isEmpty) {
    //                       return 'Password is required!';
    //                     }
    //                     return null;
    //                   },
    //                 ),
    //               ),
    //               Visibility(child: _checkButton(),
    //                 visible: otherVisible,),
    //             ],
    //           ),
    //         ),
    //       );
    //     });
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

  _checkButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () {
                setState(() {});
                if (!formKey.currentState.validate()) {
                } else if (passwordNew1.text != passwordNew2.text) {
                  _showSnackBar(
                      "password does not match", Colors.red[900], Icons.lock);
                  return 'Password does not match';
                } else {
                  changePassword();
                }
              },
              child: Text(
                'Proceed',
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

  bool isVisible = true;
  bool otherVisible = false;

  checkPassword() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var passwordKey = _prefs.getString("password");
    if (passwordOld.text != passwordKey) {
      _showSnackBar("Invalid password", Colors.red[900], Icons.lock);
      passwordOld.clear();
      myFocusNode1.hasFocus;
      return 'Invalid Password';
    } else {
      setState(() {
        isVisible = !isVisible;
        otherVisible = !otherVisible;
      });
      return null;
    }
  }

  _checkOldPasswordButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () {
                setState(() {});
                if (checkPassword()) {
                } else {
                  setState(() {
                    otherVisible = !otherVisible;
                  });
                }
              },
              child: Text(
                'Proceed',
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

  changePassword() async {
    try {
      if (await ConnectivityWrapper.instance.isConnected) {
        showAlertDialog();

        Map<String, String> data = {
          "password": passwordNew1.text,
          "confirmPassword": passwordNew2.text,
        };
        final response = await networkHandler
            .post("/api/user/edit-profile", data)
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
          returnToHome();
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(builder: (context) => ProfilePage()),
          //         (route) => false);
          _showSnackBar(
              "Changes saved successfully!", Colors.green[700], Icons.info);
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

  returnToHome() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var tempName = _prefs.getString('name');
    if (tempName == "CUSTOMER") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => CustomerHome()));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AdminDashBoard()));
    }
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

  callingDeleteUser() async {
    if (await ConnectivityWrapper.instance.isConnected) {
      showAlertDialog();
      var response = await networkHandler
          .get("/api/user/delete-profile") // getting with body is faulty!
          .timeout(Duration(seconds: 120), onTimeout: () {
        _showSnackBar("Network Timed out", Colors.red, Icons.network_check);
        Navigator.pop(context);
        throw TimeoutException(
            'The connection has timed out, please try again');
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        //Navigator.of(context).pop();
        logout();
        _showSnackBar(
            "Account deleted successfully", Colors.green[900], Icons.delete);
      } else {
        _showSnackBar(
            "Deletion failed", Colors.red[900], Icons.error_outline_sharp);
      }
    } else {
      Navigator.of(context).pop();
      _showSnackBar("No internet connection", Colors.red[900], Icons.error);
    }
  }

  //show deletion dialog
  showDeletionDialog(BuildContext context) {
    showGeneralDialog(
      barrierLabel: "Disable User",
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
                    Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            "Warning! delete action cannot be undone",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            callingDeleteUser();
                          },
                          child: Text(
                            "Delete",
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.amber,
                            onPrimary: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSnackBar("Action cancelled", Colors.green[700],
                                Icons.cancel_outlined);
                          },
                          child: Text(
                            "Cancel",
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.amber,
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
}
