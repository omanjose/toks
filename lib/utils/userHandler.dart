import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserDialog {
  handleUserDialog(
      BuildContext context, String bodyText, Function yes, Function cancel) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
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
                      Text(
                        "TOKS",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        bodyText,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: yes,
                            child: Text(
                              "Yes",
                              style: TextStyle(fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green[900],
                              onPrimary: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: cancel,
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
}
