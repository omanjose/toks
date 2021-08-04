import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/stateController/statusController.dart';
import 'package:project2/toks_model/user.dart';
import 'package:project2/utils/errorPage.dart';
import 'package:project2/utils/noItemsFound.dart';

class PaginationView extends StatefulWidget {
  const PaginationView({Key key}) : super(key: key);

  @override
  _PaginationViewState createState() => _PaginationViewState();
}

class _PaginationViewState extends State<PaginationView> {
  final _pagingController =
      PagingController<int, User>(firstPageKey: 0); //review
  static const _pageSize = 20; //review
  NetworkHandler networkHandler = new NetworkHandler();

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  // moving focus on widgets
  _nextFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  // validating inputs
  String _validateInput(String value) {
    if (value.trim().isEmpty) {
      return 'Field is required!';
    }
    return null;
  }

  bool enabled = true;
  String status = "";

  void userStatus() {
    if (enabled == true) {
      status = "Enabled";
    } else {
      status = "Disabled";
    }
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

  Future<void> _fetchPage(pageKey) async {
    try {
      final response = await networkHandler.get("api/user/get-all-profiles/CUSTOMER/$pageKey/$_pageSize")
          .timeout(Duration(seconds: 120), onTimeout: () {
        _showSnackBar("The connection timed out!", Colors.red[900], Icons.network_check);
        throw TimeoutException("The connection timed out, couldn't get user");
      });
      var res = json.decode(response.body);
      print(res);
      final responseData = res['responseData'];
      setState(() {
        userModel = User.fromJson(responseData);
      });

      return User.fromJson(responseData);

    } catch (error) {
      _pagingController.error = error;
      error.toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  final refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.white,
      backgroundColor: Colors.amber,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Return to previous screen',
        ),
        backgroundColor: Color(0xff102733),
        elevation: 3,
         title: Text("Customers", style: TextStyle(fontSize: 14)),
      ),
      body: Container(
        decoration: BoxDecoration(color:Color(0xff102733)),
        child: RefreshIndicator(
            key: refreshKey,
            child: PagedListView<int, User>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, item, index) => Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Card(
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundImage: item.profilePhoto != null
                              ? NetworkImage(item.profilePhoto)
                              : AssetImage("asset/imageicon.png"),
                        ),
                        title: Text("${item.firstName}" + " " + "${item.lastName}",
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
                                "${item.phoneNumber}\n ${item.role.name}",
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // view user on a dialog
                              TextButton(
                                style: flatButtonStyle,
                                onPressed: () {
                                  handleUserDialog(context,  "About" + " ${item.firstName} ${item.id}", callingViewUserById(), Navigator.of(context).pop);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(Icons.person,
                                        color: Colors.amber, size: 12),
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 1.0),
                                    ),
                                    Text('View', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              //disable user
                              TextButton(
                                style: flatButtonStyle,
                                onPressed: () {
                                handleUserDialog(context, "${userModel.firstName} will be temporarily inactive",  showDisableDialog(context), Navigator.of(context).pop);

                                },
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.disabled_by_default_sharp,
                                        color: Colors.amber, size: 12),
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Text('Disable', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              //enable user
                              TextButton(
                                style: flatButtonStyle,
                                onPressed: () {
                                 handleUserDialog(context, "This account will be activated",  enableUserAPI(), Navigator.of(context).pop);

                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(Icons.policy_outlined,
                                        color: Colors.amber, size: 12),
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Text(
                                      'Enable',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                firstPageErrorIndicatorBuilder: (context) => ErrorIndicatorPage(),
                noItemsFoundIndicatorBuilder: (context) => EmptyListIndicator(),
              ),
            ),
            onRefresh: () => Future.sync(
                  () => _pagingController.refresh(),
                )),
      ),
    );
  }

  //popup for user interaction on the expandibleTile
  handleUserDialog(
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

  // for disable entry form
  final _disableReason = TextEditingController();
  final _disableUserId = TextEditingController();

//Disable User API Call
  callingDisAbleAPI() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.validate();

    if (await ConnectivityWrapper.instance.isConnected) {
      showAlertDialog();
      Map<String, String> data = {
        "reason": _disableReason.text,
        "userId": _disableUserId.text,
      };
      var response = await networkHandler
          .post("/api/user/disable-profile", data)
          .timeout(Duration(seconds: 360), onTimeout: () {
        _showSnackBar("Network Timed out", Colors.red, Icons.network_check);
        Navigator.pop(context);
        throw TimeoutException(
            'The connection has timed out, please try again');
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();
        _showSnackBar("Account disabled successfully", Colors.green[800],
            Icons.disabled_by_default);
      } else {
        _showSnackBar(
            "Disabling failed", Colors.red[900], Icons.error_outline_sharp);
      }
    } else {
      Navigator.of(context).pop();
      _showSnackBar("No internet connection", Colors.red[900], Icons.error);
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

  final _formKey = GlobalKey<FormState>();
  final disableReasonNode = FocusNode();
  final disableIdNode = FocusNode();

  //show disable dialog
  showDisableDialog(BuildContext context) {
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text("Account will be inactive",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          )),
                      TextFormField(
                        focusNode: disableReasonNode,
                        decoration: InputDecoration(
                          prefixIcon:
                              Icon(Icons.info_outlined, color: Colors.black),
                          labelText: 'Reason',
                          labelStyle: TextStyle(
                              color: disableReasonNode.hasFocus
                                  ? Colors.black
                                  : Colors.grey[700]),
                          fillColor: Colors.white70,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.amber, width: 1.0)),
                          enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _validateInput,
                        onFieldSubmitted: (String value) {
                          _nextFocus(disableIdNode);
                        },
                        keyboardType: TextInputType.number,
                        controller: _disableReason,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        focusNode: disableIdNode,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.dialpad, color: Colors.black),
                          labelText: 'User ID',
                          labelStyle: TextStyle(
                              color: disableIdNode.hasFocus
                                  ? Colors.black
                                  : Colors.grey[700]),
                          fillColor: Colors.white70,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.amber, width: 1.0)),
                          enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _validateInput,
                        onFieldSubmitted: (String value) {
                          callingDisAbleAPI();
                        },
                        keyboardType: TextInputType.emailAddress,
                        controller: _disableUserId,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                             // Navigator.pop(context);
                              callingDisAbleAPI();
                            },
                            child: Text(
                              "Disable",
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.amber,
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



  // viewing user by ID
  //fix the id
  // final int id = null;
  User userModel = new User();

  // look at this properly
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
        Navigator.of(context).pop();
        displayUser();

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
        setState(() {
          userModel = User.fromJson(res);

        });
        Navigator.of(context).pop();
        _showSnackBar("${userModel.firstName} ${userModel.lastName}'s account enabled", Colors.green[800], Icons.verified_outlined);
        return User.fromJson(res);
      } else {
        _showSnackBar("Process failed, try again", Colors.red[900],
            Icons.error_outline_sharp);
      }
    }
  }

  final GetStatusController controller = Get.put(GetStatusController());

// displaying found user information
  displayUser() {
    showDialog(
      context: context,
      barrierColor: Color(0xff102733),
      barrierDismissible: false,
      builder: (context) => Card(
        elevation: 4,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: RefreshIndicator(
            onRefresh: () => Future.sync(() => callingViewUserById()),
            child: FutureBuilder<User>(
              future: callingViewUserById(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 14, bottom: 14, left: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xff102733),
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
                            Text("Account type ${snapshot.data.role.name}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.amber,
                        thickness: 2,
                        height: 2,
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.person, size: 15, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                              "${snapshot.data.firstName}  ${snapshot.data.firstName}",
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: Colors.amber,
                        thickness: 2,
                        height: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: FittedBox(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(8)),
                            child: GetBuilder<GetStatusController>(
                              builder:(_) {
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("${_.status}",
                                          style: TextStyle(
                                              color: Colors.green[700],
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700)),
                                      SizedBox(width: 8),
                                      Icon(
                                        enabled
                                            ? Icons.policy_outlined
                                            : Icons.warning_amber_outlined,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ]);
                              }
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.amber,
                        thickness: 2,
                        height: 1,
                      ),
                      Row(
                        children: [
                          Icon(Icons.email, size: 15, color: Colors.white),
                          SizedBox(width: 10),
                          Text("${snapshot.data.emailAddress}",
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: Colors.amber,
                        thickness: 2,
                        height: 1,
                      ),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 15, color: Colors.white),
                          SizedBox(width: 10),
                          Text("${snapshot.data.phoneNumber}",
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 16)),
                        ],
                      ),
                      SizedBox(height:8),
                  Row(
                         mainAxisAlignment:MainAxisAlignment.spaceBetween,
                         children: [
                           SizedBox.fromSize(
                             size: Size(60, 60), // button width and height
                             child: ClipOval(
                               child: Material(
                                 color: Colors.amber, // button color
                                 child: InkWell(
                                   splashColor: Colors.amber[900], // splash color
                                   onTap: () {
                                     controller.enableUserAPI();
                                  // Get.find<GetStatusController>().enableUserAPI();
                                   }, // button pressed
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: <Widget>[
                                       Icon(Icons.policy_outlined, color: Colors.black),
                                       SizedBox(height: 4), // icon
                                       Text(
                                         "Enable",
                                         style: TextStyle(
                                             color: Colors.black,
                                             fontSize: 10,
                                             fontWeight: FontWeight.bold),
                                       ), // text
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                           ),
                           SizedBox.fromSize(
                             size: Size(60, 60), // button width and height
                             child: ClipOval(
                               child: Material(
                                 color: Colors.amber, // button color
                                 child: InkWell(
                                   splashColor: Colors.amber[900], // splash color
                                   onTap: () {
                                     callingDisAbleAPI();
                                   }, // button pressed
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: <Widget>[
                                       Icon(Icons.security, color: Colors.black),
                                       SizedBox(height: 4), // icon
                                       Text(
                                         "Disabled",
                                         style: TextStyle(
                                             color: Colors.black,
                                             fontSize: 10,
                                             fontWeight: FontWeight.bold),
                                       ), // text
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                           ),
                         ],
                       ),

                    ],
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
                                  'No Connection',
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
                                                displayUser())).then((context) {
                                      callingViewUserById();
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
                }
                return Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.amber));
              },
            ),
          ),
        ),
      ),
    );
  }
}
