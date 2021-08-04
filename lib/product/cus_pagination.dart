import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/toks_model/user.dart';
import 'package:project2/utils/errorPage.dart';

class UserPagination extends StatefulWidget {
  const UserPagination({Key key}) : super(key: key);

  @override
  _UserPaginationState createState() => _UserPaginationState();
}

class _UserPaginationState extends State<UserPagination> {
  bool _hasMore;
  int _pageNumber;
  bool _error;
  bool _loading;
  int _pageSize = 10;

  final int _defaultUserPerPageCount = 10;
  List<User> _users;
  final int _nextPageThreshold = 5;
  @override
  void initState() {
    _hasMore = true;
    _pageNumber = 0;
    _error = false;
    _loading = true;
    _users = [];
    fetchUsers();
    super.initState();
  }

NetworkHandler networkHandler = new NetworkHandler();

  Future<void> fetchUsers() async {
    try {
      var response = await networkHandler.get("/api/user/get-all-profiles/ADMIN/" +
                  "$_pageNumber" +
                  "/" +
                  "$_pageSize") .timeout(Duration(seconds: 120), onTimeout: () {
        _showSnackBar("The connection timed out!", Colors.red[900], Icons.network_check);
        throw TimeoutException("The connection timed out, couldn't get user");
      });
      final jsonResponse = json.decode(response.body);

      List res = jsonResponse['responseData'];

      var data = res.map((item) => new User.fromJson(item)).toList();
      setState(() {
        _hasMore = data.length == _defaultUserPerPageCount;
        _loading = false;
        _pageNumber = _pageNumber++;
        _users.addAll(data);
      });
    } catch (e) {
      print("error :" + e.toString());
      setState(() {
        _loading = false;
        _error = true;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Return to previous screen',
        ),
        backgroundColor: Color(0xff102733),
        elevation: 3,
        // title: Text("Customers", style: TextStyle(fontSize: 14)),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    if (_users.isEmpty) {
      if (_loading) {
        return dialogLoader();
      } else if (_error) {
        return RefreshIndicator(
          child: ErrorIndicatorPage(),
          onRefresh: () => Future.sync(
            () => fetchUsers(),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: _users.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _users.length - _nextPageThreshold) {
                fetchUsers();
              }
              if (index == _users.length) {
                if (_error) {
                  return RefreshIndicator(
                    child: ErrorIndicatorPage(),
                    onRefresh: () => Future.sync(
                      () => fetchUsers(),
                    ),
                  );
                } else {
                  return dialogLoader();
                }
              }
              final User user = _users[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Card(
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundImage: user.profilePhoto != null
                          ? Image.network(user.profilePhoto)
                          : AssetImage("asset/imageicon.png"),
                    ),
                    title: Text("${user.firstName}" + " " + "${user.lastName}",
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
                            "${user.phoneNumber}\n ${user.role.name}",
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
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              _dialog(
                                  context,
                                  "About" +
                                      "${user.firstName}" +
                                      " " +
                                      "${user.lastName}", () {
                                //   callingViewUserById();
                                Navigator.of(context).pop();
                              }, () {
                                Navigator.of(context).pop();
                              });
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
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.policy_outlined,
                                    color: Colors.amber, size: 12),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Disable', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              // showDeleteDialog();
                              Navigator.of(context).pop();
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // Icon(Icons.swap_vert),
                                Icon(Icons.delete,
                                    color: Colors.amber, size: 12),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text(
                                  'Delete',
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
      }
    }
    return Container();
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    primary: Colors.white,
    backgroundColor: Colors.amber[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
  );

  //popup for user interaction on the expandibleTile
  _dialog(
      BuildContext context, String bodyText, Function yes, Function cancel) {
    showGeneralDialog(
      barrierLabel: "Toks",
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
                          Expanded(
                            child: ElevatedButton(
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
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
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

  // Alert dialog
  dialogLoader() {
    showDialog(
      context:context,
      barrierColor:Color(0xff102733),
      barrierDismissible: false,
      builder: (context)=>
          WillPopScope(
            onWillPop: ()async=>false,
            child: SimpleDialog(
              elevation:0,
              backgroundColor: Color(0xff102733),
              children: [
                Center( child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(child:CircularProgressIndicator(color: Colors.amber)),
                    Text('Please wait...', style:TextStyle(fontSize:12,color:Colors.amber),),
                  ],
                ),),

              ],
            ),
          ),
    );
  }
}
