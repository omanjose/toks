import 'package:flutter/material.dart';

class EmptyListIndicator extends StatefulWidget {
  const EmptyListIndicator({Key key}) : super(key: key);

  @override
  _EmptyListIndicatorState createState() => _EmptyListIndicatorState();
}

class _EmptyListIndicatorState extends State<EmptyListIndicator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff102733),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Center(
                child: Icon(
              Icons.hourglass_empty,
              color: Colors.amber,
              size: 130,
            )),
            SizedBox(
              height: 70,
            ),
            Text(
              'Too much filtering',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Center(
                child: Text(
              "We couldn't find any results matching your applied filters",
              style: TextStyle(color: Colors.amber),
            )),
          ],
        ),
      ),
    );
  }
}
