import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project2/dashboard/admin_dashboard.dart';
import 'package:project2/dashboard/customer_home.dart';
import 'package:project2/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile.dart';
import 'search.dart';

class CustomerDashBoard extends StatefulWidget {
  @override
  _CustomerDashBoardState createState() => _CustomerDashBoardState();
}

class _CustomerDashBoardState extends State<CustomerDashBoard>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  TabController _tabController;
  final storage = FlutterSecureStorage();
  var dbuserPic, dbfname, dblname, dbemail, dinit, dname, dlname, demail = "";
  Widget profilePic;

  getData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      dbfname = _prefs.getString("fname");
      dblname = _prefs.getString("lname");
      dinit = _prefs.getString("initials");
      dbuserPic = (_prefs.getString("profilePhoto"));

      dbemail = _prefs.getString("email");
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              new SliverAppBar(
                leading: IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () => _scaffoldKey.currentState.openDrawer(),
                ),
                actions: [
                  IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () {}),
                ],
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                bottom: new TabBar(controller: _tabController, tabs: <Tab>[
                  new Tab(
                    icon: Icon(Icons.home),
                  ),
                  new Tab(
                    icon: Icon(Icons.collections),
                  ),
                  new Tab(
                    icon: Icon(Icons.category),
                  )
                ]),
              )
            ];
          },
          body: new TabBarView(
            children: [new CustomerHome(), new ProfilePage(), new SearchPage()],
            controller: _tabController,
          ),
        ),
      ),
      drawer: Drawer(
        elevation: 0,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: dbuserPic != null
                    ? NetworkImage(dbuserPic)
                    : AssetImage('asset/imageicon.png'),
              ),
              accountEmail: Text(dbemail,
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              accountName: Text(dbfname + " " + dblname,
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              decoration: BoxDecoration(color: Colors.blueGrey[700]),
            ),
            Expanded(
                flex: 7,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      trailing: Icon(Icons.arrow_forward_ios_sharp),
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => UserProfile()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      trailing: Icon(Icons.arrow_forward_ios_sharp, size: 8),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text('About'),
                      trailing: Icon(Icons.arrow_forward_ios_sharp, size: 10),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.privacy_tip),
                      title: Text('Privacy'),
                      trailing: Icon(Icons.arrow_forward_ios_sharp, size: 12),
                      onTap: () {},
                    ),

                    ListTile(
                      leading: Icon(Icons.privacy_tip),
                      title: Text(' Admin DashBoard'),
                      trailing: Icon(Icons.arrow_forward_ios_sharp, size: 12),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminDashBoard()));
                      },
                    ),

                    ListTile(
                      title: Text("Logout"),
                      trailing: Icon(Icons.power_settings_new),
                      onTap: logout,
                    ),
                    // Consumer<ThemeNotifier>(
                    //   builder: (context, notifier, child) => SwitchListTile(
                    //     title: Text('Dark Mode'),
                    //     onChanged: (value) {
                    //       notifier.toggleTheme();
                    //     },
                    //     value: notifier.darkTheme,
                    //   ),
                    //  ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void logout() async {
    await storage.delete(key: "token");
    await storage.deleteAll();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
  }
}
