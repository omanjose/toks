import 'dart:async';
import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/toks_model/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:project2/shimmer_objects/shimmer_list.dart';
import 'package:project2/utils/errorPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetReportList extends StatefulWidget {
  @override
  _WidgetReportListState createState() => _WidgetReportListState();
}

class _WidgetReportListState extends State<WidgetReportList> {

  User userModel = User();
  final _formKey = GlobalKey<FormState>();
  var refreshKey = new GlobalKey<RefreshIndicatorState>();

  Future<List<User>> getProfile() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String token = _prefs.getString("storage");
    final response = await http.get(
        Uri.parse(
            "http://toks.herokuapp.com/api/user/get-all-profiles-np/CUSTOMER"),
        headers: {"Authorization": "Bearer $token"});
    final jsonResponse = json.decode(response.body);
    List res = jsonResponse['responseData'];
    return res.map((item) => new User.fromJson(item)).toList();
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.white,
      backgroundColor: Colors.amber[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );

    final _refreshKey = GlobalKey<RefreshIndicatorState>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Return to previous screen',
        ),
        backgroundColor: Color(0xff102733),
        elevation: 3,
        title: Text("Customers", style: TextStyle(fontSize: 14)),
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xff102733)),
        child: RefreshIndicator(
          key:_refreshKey,
          onRefresh: () => Future.sync(() => getProfile()),
          child: FutureBuilder<List<User>>(
            future: getProfile(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      // return Text("${snapshot.data[5].firstName}");
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundImage:
                                  snapshot.data[index].profilePhoto != null
                                      ? Image.network(
                                          snapshot.data[index].profilePhoto)
                                      : AssetImage("asset/imageicon.png"),
                            ),
                            title: Text(
                                "${snapshot.data[index].firstName}" +
                                    " " +
                                    "${snapshot.data[index].lastName}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    "${snapshot.data[index].phoneNumber}\n ${snapshot.data[index].role.name}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(fontSize: 15),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 1.0,
                                height: 1.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  //view customer profile dialog
                                  TextButton(
                                    style: flatButtonStyle,
                                    onPressed: () {

                                      showUseProfile();
                                       // Navigator.of(context).pop();

                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.person,
                                            color: Colors.amber, size: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1.0),
                                        ),
                                        Text('View',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),

                                  //Disable customer
                                  TextButton(
                                    style: flatButtonStyle,
                                    onPressed: () {
                                      _dialog(context, "Account will temporarily inactive", showDisableDialog(), Navigator.of(context).pop);
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Icon(Icons.disabled_by_default_sharp,
                                            color: Colors.amber, size: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        //Disable widget
                                        Text('Disable',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    style: flatButtonStyle,
                                    onPressed: () {
                                     _dialog(context, "Account will be activated", enableUserAPI(), Navigator.of(context).pop);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.policy_outlined,
                                            color: Colors.amber, size: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Text(
                                          'Enable',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.error != null) {
                // return Center(child: Text("${snapshot.error}"));
                return SingleChildScrollView(child: ErrorIndicatorPage());
              }
              return ShimmerList();
            },
          ),
        ),
      ),
    );
  }

  //popup for user interaction on the expandibleTile
  _dialog(
      BuildContext context, String bodyText, Function yes, Function cancel) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
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
                        bodyText,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => yes,
                            child: Text(
                              "Yes",
                              style: TextStyle(fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => cancel,
                            child: Text(
                              "Cancel",
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



//Disable User API call
  callingDisAbleAPI() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String token = _prefs.getString("storage");
    http.Response response = await http.post(
      Uri.parse("https://toks.herokuapp.com/api/user/disable-profile"),
      body: {
        "reason": _reason.text,
        "userId": _userId.text,
      },
      headers: {
        "Authorization": "Bearer $token",
        "Content-type": "application/json",
      },
    );
    if (response.statusCode == 200 || response.statusCode==201){
      print('Account disabled successfully');
      Navigator.of(context).pop();
      _showSnackBar("Account successfully disabled", Colors.green[700], Icons.delete);
    }else{
      _showSnackBar("Account disabling failed", Colors.red[900], Icons.error);
      Navigator.of(context).pop();
    }
  }

  //Profile dialog display
  showUseProfile() {
    return showGeneralDialog(
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.blue[900],
        transitionDuration: Duration(microseconds: 200),
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                  future: callingViewUserById(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        child: FittedBox(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 80.0,
                                width: 80.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: snapshot.data.profilePhoto != null
                                        ? NetworkImage(
                                            snapshot.data.profilePhoto)
                                        : AssetImage("asset/imageicon.png"),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 1.5,
                                height: 1.5,
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blueGrey),
                                  SizedBox(width: 5),
                                  Text(
                                    "${snapshot.data.firstName}" +
                                        " " +
                                        "${snapshot.data.lastName}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 1,
                                height: 1,
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.mail, color: Colors.blueGrey),
                                  SizedBox(width: 5),
                                  Text(
                                    "${snapshot.data.emailAddress}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 1,
                                height: 1,
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.blueGrey),
                                  SizedBox(width: 10),
                                  Text(
                                    "${snapshot.data.phoneNumber}" ??
                                        "Not available",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 1,
                                height: 1,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        decoration: BoxDecoration(color: Color(0xff102733)),
                        child: Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(height: 20),
                                Center(
                                  child: Icon(Icons.sentiment_dissatisfied,
                                      color: Colors.amber, size: 130),
                                ),
                                SizedBox(height: 50),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'No internet connection',
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Center(
                                      child: Text(
                                        "Please check your internet connection",
                                        style: TextStyle(color: Colors.amber),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Center(
                                        child: IconButton(
                                          icon: Icon(Icons.refresh,
                                              size: 20, color: Colors.amber),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WidgetReportList())).then((context) {
                                              getProfile();
                                            });
                                          },
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoActivityIndicator(
                              radius: 18,
                            ),
                            Text('Please wait...',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }
                  }),
            ),
          );
        });
  }

  //text editing controllers for the disableUser popup form
  final _reason = TextEditingController();
  final _userId = TextEditingController();

//disable user popup UI
  showDisableDialog() {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black45,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Center(
            child: Container(
              decoration: BoxDecoration(color: Color(0xff102733)),
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Text(
                    "Provide the account to disable",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    // style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.unsubscribe),
                        alignLabelWithHint: true,
                        // hintText: 'Last name',
                        labelText: 'Reason :',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700])),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue[700]))),
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value.isEmpty ? 'Reason is required' : null,

                    keyboardType: TextInputType.text,
                    controller: _reason,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    // style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.padding),
                        alignLabelWithHint: true,
                        // hintText: 'User ID',
                        labelText: 'User ID',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700])),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue[700]))),
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value.isEmpty ? 'UserId is required' : null,

                    keyboardType: TextInputType.number,
                    controller: _userId,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              if (!_formKey.currentState.validate()) {
                                return;
                              } else {
                                _dialog(context,
                                    "This user will temporarily be inactive",
                                    () {
                                  callingDisAbleAPI();
                                 // Navigator.of(context).pop();
                                }, () {
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                            child: Text(
                              'Disable',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                              elevation: 5,
                              // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

NetworkHandler networkHandler = new NetworkHandler();
  callingViewUserById() async {
    if (await ConnectivityWrapper.instance.isConnected) {
      showAlertDialog();

      var response = await networkHandler
          .get(
          "/api/user/get-profile/${userModel.id}") // getting with body is faulty!
          .timeout(Duration(seconds: 360), onTimeout: () {
        _showSnackBar("Network Timed out", Colors.red, Icons.network_check);
        Navigator.pop(context);
        throw TimeoutException(
            'The connection has timed out, please try again');
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = json.decode(response.body);
        var res = data['responseData'];
        print(data);
        setState(() {
          userModel = User.fromJson(res);
          // print(userModel.firstName + " " + userModel.emailAddress);
        });
       // Navigator.of(context).pop();
        showUseProfile();
        return User.fromJson(res);
      } else {
        _showSnackBar("Process failed, try again", Colors.red[900],
            Icons.error_outline_sharp);
      }
    } else {
      Navigator.of(context).pop();
      _showSnackBar("No internet connection", Colors.red[900], Icons.error);
    }
  }

  enableUserAPI()async{
    if (await ConnectivityWrapper.instance.isConnected){
      showAlertDialog();

      var response = await networkHandler
          .get(
          "/api/user/enable-profile/${userModel.id}") // getting with body is faulty!
          .timeout(Duration(seconds: 120), onTimeout: () {
        _showSnackBar("Network Timed out", Colors.red, Icons.network_check);
        Navigator.pop(context);
        throw TimeoutException(
            'The connection has timed out, please try again');
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = json.decode(response.body);
        var res = data['responseData'];

        Navigator.of(context).pop();
        _showSnackBar("${userModel.firstName} ${userModel.lastName}'s account enabled", Colors.green[800], Icons.verified_outlined);
        return User.fromJson(res);
      } else {
        _showSnackBar("Activation failed, try again", Colors.red[900],
            Icons.error_outline_sharp);
        Navigator.of(context).pop();
      }
    }
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
            // Center(
            //
            //      child: CircularProgressIndicator(
            //         backgroundColor: Colors.amber
            //       ),
            //
            //   ),
            // SizedBox(height:10),
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

  // Multipurpose snackBar
  void _showSnackBar(String message, Color color, IconData icon){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          content: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Icon(icon,color: Colors.white, size: 14),
            SizedBox(width: 15),
            Expanded(
              child: Text(message,style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),),
          ]),
          duration: const Duration(seconds: 3),));
  }
}
