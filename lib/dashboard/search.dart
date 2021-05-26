import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project2/dashboard/widget_builder.dart';

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
      body: SafeArea(
        child: Container(
          child: WidgetReportList(),
        ),
      ),
    );
  }
}
