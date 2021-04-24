import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project2/dashboard/admin_dashboard.dart';
import 'package:project2/password_recovery.dart';
import 'package:project2/signup.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'api_controller/controller.dart';

const SERVER_IP = 'http://toks.herokuapp.com';

void main() {
  //runApp(MyApp());
  return runApp(ChangeNotifierProvider(
    create: (context) => Auth(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      builder: EasyLoading.init(),
      // routes: 'signup',
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Auth auth;
  final storage = new FlutterSecureStorage();
  final emailCtrl = TextEditingController();

  final passwordCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userEmail, _userPassword;

  bool _isObscure = true;

  final _scaffoldMessenger = GlobalKey<ScaffoldMessengerState>();

  void _showSnackBar(String text, String label) {
    _scaffoldMessenger.currentState.showSnackBar(new SnackBar(
      content: new Text(text),
      action: SnackBarAction(label: label, onPressed: null),
    ));
  }

  void _tryToAuthenticate() async {
    String token = await storage.read(key: 'token');
    Provider.of<Auth>(context, listen: false).attempt(token: token);
  }

  @override
  void initState() {
    _tryToAuthenticate();
    super.initState();
  }

  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  bool isLoading = false;

  final spinkit = SpinKitDoubleBounce(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
          decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index.isEven ? Colors.blue[800] : Colors.grey,
      ));
    },
  );

  Widget _loginButton() {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading'),
          )
        : Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState.validate()) {
                          return;
                        }

                        formKey.currentState.save();
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          final newUser =
                              await Provider.of<Auth>(context, listen: false)
                                  .signIn(emailCtrl.text, passwordCtrl.text);
                          print(newUser.toString());
                          if (newUser != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminDashBoard()));
                          }
                        } catch (e) {
                          EasyLoading.showError(e.toString());
                          setState(() => isLoading = false);
                          _showSnackBar(
                              "Toks", "Some errors occured, could not Login");
                          throw Exception(e.toString());
                        }
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        onPrimary: Colors.white,
                        // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      )),
                ),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Container(
          height: size.height,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Form(
                  key: formKey,
                  child: Container(
                    //alignment: Alignment.bottomCenter,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // flex: 1,
                          child: Container(
                            // alignment: Alignment(0.0, 1.0),
                            height: 270,
                            width: size.width,
                            decoration: BoxDecoration(
                              //borderRadius: BorderRadius.only(
                              // topLeft: Radius.circular(15),
                              // topRight: Radius.circular(15)),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage("asset/tokspic.jpg")),
                            ),
                            child: Center(
                              // alignment: Alignment.center,
                              child: Text(
                                'Toks',
                                style: GoogleFonts.lato(
                                  fontSize: 50,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          // flex: 1,
                          child: Container(
                            color: Colors.black,
                            alignment: Alignment.bottomCenter,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15)),
                              ),
                              child: ListView(
                                children: [
                                  // Container(
                                  //   child: Text(
                                  //     'Login ',
                                  //     style: TextStyle(
                                  //       color: Colors.blue[700],
                                  //       fontSize: 30.0,
                                  //       fontWeight: FontWeight.bold,
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      validator: (value) =>
                                          EmailValidator.validate(value)
                                              ? null
                                              : "Invalid Email Address",
                                      onSaved: (value) {
                                        _userEmail = value;
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                      controller: emailCtrl,
                                      decoration: InputDecoration(
                                        icon: Icon(Icons.email),
                                        // border: OutlineInputBorder(
                                        //     borderRadius: BorderRadius.circular(20)
                                        //     ,),
                                        alignLabelWithHint: true,
                                        hintText: 'you@example.com',
                                        labelText: 'Email',
                                        // border: OutlineInputBorder(),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blue[700]),
                                        ),
                                      ),
                                    ),
                                  ),
                                  //SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      maxLength: 40,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      controller: passwordCtrl,
                                      decoration: InputDecoration(
                                        //labelText: 'Password',
                                        icon: Icon(Icons.lock),
                                        // border: OutlineInputBorder(
                                        //     borderRadius: BorderRadius.circular(20)
                                        //     ,),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isObscure
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isObscure = !_isObscure;
                                            });
                                          },
                                        ),
                                        alignLabelWithHint: true,
                                        hintText: 'Password',
                                        labelText: 'Password',
                                        // border: OutlineInputBorder(),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blue[700]),
                                        ),
                                      ),
                                      obscureText: _isObscure,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Password is required!';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _userPassword = value;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Container(
                                    alignment: Alignment(1.0, 0.0),
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PasswordRecovery()));
                                      },
                                      child: Text(
                                        'Forgot Password',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  _loginButton(),
                                  SizedBox(height: 5),
                                  Center(
                                    child: Text(
                                      'Don\'t have an account?',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Center(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignUpPage()));
                                      },
                                      child: Text(
                                        'Create account',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
