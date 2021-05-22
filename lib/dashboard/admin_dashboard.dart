import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project2/dashboard/search.dart';
import 'package:project2/profile.dart';
import 'package:project2/utils/userHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/dashboard/collections.dart';
import 'package:project2/dashboard/customer_dashboard.dart';
import 'package:project2/dashboard/settings.dart';
import 'package:project2/login.dart';

class AdminDashBoard extends StatefulWidget {
  @override
  _AdminDashBoardState createState() => _AdminDashBoardState();
}

class _AdminDashBoardState extends State<AdminDashBoard> {
  int currentState = 0;
  List<Widget> widgets = [
    CollectionsPage(),
    SearchPage(),
    ProfilePage(),
    SettingsPage()
  ];
  List<String> titleString = ["Dashboard", "Search", "Account", "Settings"];
  final storage = FlutterSecureStorage();
  NetworkHandler networkHandler;
  UserDialog usd;

  BuildContext context;
  var dbuserPic,
      dbfname,
      dblname,
      dbemail,
      dinit,
      dname,
      dlname,
      dPic,
      demail = "";
  Widget profilePic;
  @override
  void initState() {
    super.initState();
    getData();
    networkHandler = NetworkHandler();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String newPic;
  getData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      dbfname = _prefs.getString("fname");
      dblname = _prefs.getString("lname");
      dinit = _prefs.getString("initials");
      dbuserPic = (_prefs.getString("profilePhoto"));
      newPic = (dbuserPic != null ? dbuserPic : dinit);

      dbemail = _prefs.getString("email");
    });
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return SafeArea(child: _dashboardUI());
  }

  _dashboardUI() {
    return Scaffold(
      // drawer: Drawer(
      //   child: ListView(
      //     physics: BouncingScrollPhysics(),
      //     shrinkWrap: true,
      //     children: <Widget>[
      //       DrawerHeader(
      //         child: Column(
      //           children: <Widget>[
      //             profilePic,
      //             SizedBox(
      //               height: 10,
      //             ),
      //             Text('$dname+""+$dlname')
      //           ],
      //         ),
      //       ),
      //       ListTile(
      //         title: Text("Collections"),
      //         trailing: Icon(Icons.launch),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text("Categories"),
      //         trailing: Icon(Icons.add),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text("Settings"),
      //         trailing: Icon(Icons.settings),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text("Feedback"),
      //         trailing: Icon(Icons.feedback),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text("Tempory to CustomerDashBoard"),
      //         trailing: Icon(Icons.timelapse_outlined),
      //         onTap: () {
      //           Navigator.of(context).push(MaterialPageRoute(
      //               builder: (context) => CustomerDashBoard()));
      //         },
      //       ),
      //       ListTile(
      //         title: Text("Logout"),
      //         trailing: Icon(Icons.power_settings_new),
      //         onTap: logout,
      //       ),
      //     ],
      //   ),
      // ),
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: Center(
          child: Text(
            titleString[currentState],
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        leading: Text(''),
        actions: [
          // IconButton(
          //     icon: Icon(
          //       Icons.more_vert,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {})
          PopupMenuButton<String>(onSelected: (value) {
            print(value);
          }, itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: InkWell(
                    child: Text('Logout'),
                    onTap: () {
                      usd.handleUserDialog(
                          context,
                          "You will be signed out of the application",
                          logout,
                          () => Navigator.of(context).pop());
                    }),
              ),
              PopupMenuItem(
                child: InkWell(
                  child: Text('Customer page'),
                  onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomerDashBoard()),
                      (Route<dynamic> route) => false),
                ),
              ),
              PopupMenuItem(child: Text("About"), value: "About"),
              PopupMenuItem(child: Text("Feedback"), value: "Feedback"),
            ];
          }),
        ],
      ),
      body: widgets[currentState],
      bottomNavigationBar: TitledBottomNavigationBar(
          currentIndex:
              currentState, // Use this to update the Bar giving a position
          onTap: (index) {
            print("Selected Index: $index");
            setState(() {
              currentState = index;
            });
          },
          reverse: true,
          inactiveColor: Colors.blueGrey,
          activeColor: Colors.blue[900],
          items: [
            TitledNavigationBarItem(title: Text('Home'), icon: Icons.home),
            TitledNavigationBarItem(title: Text('Search'), icon: Icons.search),
            TitledNavigationBarItem(title: Text('Account'), icon: Icons.person),
            TitledNavigationBarItem(
                title: Text('Settings'), icon: Icons.settings),
          ]),
    );
  }

  void logout() async {
    await storage.delete(key: "token");
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
  }
}
