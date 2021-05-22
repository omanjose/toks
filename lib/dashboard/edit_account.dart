import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project2/api_controller/networkHandler.dart';


class EditAccountPage extends StatefulWidget {
  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  NetworkHandler networkHandler;
  Map user;
  List userData;
  

  getUserProfile() async {
    // var response = await networkHandler.get("/api/user/get-profile/$id");

    //   print(user);
    //   setState(() {
    //     dataModel = DataModel.fromJson(response['data']);
    //   });
  }

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  //physics: BouncingScrollPhysics,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(top: 20, bottom: 20, left: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                // color: Colors.grey[200],
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(50)),
                            width: 20,
                            height: 20,
                            child: InkWell(
                              child: Center(
                                child: Text(
                                  'X',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          child: Center(
                            child: Text('Edit user settings!',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700])),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          child: CircularProfileAvatar(
                            'cPic',
                            initialsText: Text('textfield actually'),
                            radius: 30,
                            placeHolder: (context, url) => Container(
                              height: 30,
                              width: 30,
                              child: CupertinoActivityIndicator(
                                  radius: 20, animating: true),
                            ),
                            cacheImage: true,
                            showInitialTextAbovePicture: false,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          } else {
            return Center(
              child: Text("${snapshot.error}"),
            );
          }
        });
  }
}
