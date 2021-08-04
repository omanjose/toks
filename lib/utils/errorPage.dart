import 'package:flutter/material.dart';


class ErrorIndicatorPage extends StatefulWidget {
  const ErrorIndicatorPage({Key key}) : super(key: key);

  @override
  _ErrorIndicatorPageState createState() => _ErrorIndicatorPageState();
}

class _ErrorIndicatorPageState extends State<ErrorIndicatorPage> {
  Function onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: AppBar(
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back_ios, color: Colors.amber),
      //     onPressed: () => Navigator.pop(context),
      //     tooltip: 'Return to previous screen',
      //   ),
      //   backgroundColor: Color(0xff102733),
      //   elevation: 2,
      // ),
      backgroundColor: Color(0xff102733),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 20),
            Center(
              child: Icon(Icons.sentiment_dissatisfied,
                  color: Colors.amber, size: 130),
            ),
            SizedBox(height: 30),
            Column(
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


              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
