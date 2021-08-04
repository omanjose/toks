import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project2/dashboard/widget_builder.dart';


import 'adminReportList.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xff102733),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xff102733),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: ListView(
              children: [
                Divider(
                  thickness: 4.0,
                  height: 1.0,
                ),
                Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text('View Customers',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.search),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WidgetReportList()),
                      );
                    },
                  ),
                ),
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text('View Administrators',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.search),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminReportList()),
                      );
                    },
                  ),
                ),
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text('Paginate Administrators',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.find_in_page),
                    onTap: () {
                      //  Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => UserPagination()),
                      // );
                    },
                  ),
                ),
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text('Search Customers',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.find_in_page),
                  ),
                ),
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text('View All Disabled',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.find_in_page),
                    onTap: () {},
                  ),
                ),
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
