import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project2/api_controller/networkHandler.dart';
import 'package:project2/dashboard/search.dart';
import 'package:project2/toks_model/user.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CollectionsPage extends StatefulWidget {
  @override
  _CollectionsPageState createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final storage = new FlutterSecureStorage();
  User user;
  NetworkHandler networkHandler;
  var fname, lname, userPic, email, cname, clname, cPic, cemail, cInitials = "";
  Widget boardPic;
  var newPic;
  DateTime dateToday =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    getData();
    _seriesPieData = [];
    _generateData();
    super.initState();
  }

  getData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      cname = _prefs.getString("fname");
      clname = _prefs.getString("lname");
      cPic = _prefs.getString("profilePhoto");
      cInitials = _prefs.getString("initials");
      newPic = (cPic != null ?? '');
      cemail = _prefs.getString("email");

      boardPic = CircleAvatar(
        radius: 20,
        backgroundImage: cPic != null
            ? NetworkImage(cPic)
            : AssetImage('asset/imageicon.png'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return collectionsUI();
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  collectionsUI() {
    return Container(
      child: Center(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                ),
                height: 90,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 5),
                            //profile picture is here!
                            child: Container(child: boardPic),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(
                                  greeting() + ', $cname ' + '$clname!',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  "$cemail",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Text(
                                '$dateToday',
                                // getCurrentDate(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox.fromSize(
                    size: Size(60, 60), // button width and height
                    child: ClipOval(
                      child: Material(
                        color: Colors.blue[900], // button color
                        child: InkWell(
                          splashColor: Colors.blue[500], // splash color
                          onTap: () {}, // button pressed
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.verified_user_outlined,
                                  color: Colors.amber), // icon
                              Text(
                                "Enabled",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
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
                        color: Colors.blue[900], // button color
                        child: InkWell(
                          splashColor: Colors.blue[500], // splash color
                          onTap: () {}, // button pressed
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.policy_outlined,
                                  color: Colors.amber), // icon
                              Text(
                                "Disabled",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
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
                        color: Colors.blue[900], // button color
                        child: InkWell(
                          splashColor: Colors.blue[500], // splash color
                          onTap: () {}, // button pressed
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.commute_outlined,
                                  color: Colors.amber), // icon
                              Text(
                                "Cars",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
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
                        color: Colors.blue[900], // button color
                        child: InkWell(
                          splashColor: Colors.blue[500], // splash color
                          onTap: () {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) async {
                              await Future.delayed(Duration(seconds: 2));
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SearchPage()));
                            });
                          }, // button pressed
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.person_search_outlined,
                                  color: Colors.amber), // icon
                              Text(
                                "Search User",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ), // text
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // lineChartAnalysis(),
              pieChartAnalysis(),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Toks terms and conditions applied',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

//Pie chart widget
  Expanded pieChartAnalysis() {
    return Expanded(
      child: charts.PieChart(
        _seriesPieData,
        animate: true,
        animationDuration: Duration(seconds: 3),
        //Getting more details on our chart, eg the key values indcation
        //Note: without these, our chart will show
        behaviors: [
          new charts.DatumLegend(
            outsideJustification: charts.OutsideJustification.middleDrawArea,
            horizontalFirst: false,
            desiredMaxRows: 1,
            cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
            entryTextStyle: charts.TextStyleSpec(
              color: charts.MaterialPalette.purple.shadeDefault,
              fontSize: 10,
            ),
          ),
        ],
        //Controlling the radius of the piechart and giving it labels
        defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 100,
          arcRendererDecorators: [
            new charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.auto,
            ),
          ],
        ),
      ),
    );
  }

  //series definition

  List<charts.Series<Items, String>> _seriesPieData;
  _generateData() {
    var pieData = [
      new Items('Enabled Users', 500.1, Colors.teal),
      new Items('Disabled Users', 92.8, Colors.amber[600]),
      new Items('Admin', 25.5, Colors.blue),
    ];

    //adding the pieData inside the _series list data
    _seriesPieData.add(
      charts.Series(
        data: pieData,
        domainFn: (Items items, _) => items.enabledUsers,
        measureFn: (Items items, _) => items.disabledUsers,
        id: "Current Review",
        colorFn: (Items items, _) =>
            charts.ColorUtil.fromDartColor(items.colorValue),
        labelAccessorFn: (Items row, _) => '${row.enabledUsers}',
      ),
    );
  }
}

//Class for piechart
class Items {
  String enabledUsers; //salesItem
  double disabledUsers; //quantity
  Color colorValue;

  Items(this.enabledUsers, this.disabledUsers, this.colorValue);
}
