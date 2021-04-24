import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:project2/main.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  File _imageFile;
  final picker = ImagePicker();
  bool _isObscure = true;
  bool _terms = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessenger = GlobalKey<ScaffoldMessengerState>();

  //pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
        _showSnackBar('No image selected', 'Toks', null);
      }
    });
  }

  //crop image
  Future<void> cropImage() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blueGrey,
            toolbarWidgetColor: Colors.white,
            toolbarTitle: 'Crop',
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          title: 'Crop',
          hidesNavigationBar: false,
        ));
    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Register'),
      // ),
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20, left: 10),
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
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                  ),
                  child: Center(
                      child: InkWell(
                    child: CircleAvatar(
                      radius: 60,
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(77),
                              child: Image.file(
                                _imageFile,
                                width: 110,
                                height: 110,
                                fit: BoxFit.fill,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50)),
                              width: 95,
                              height: 95,
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[800],
                              ),
                            ),
                    ),
                    onTap: () => takeShot(context),
                  )),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      //borderRadius: BorderRadius.only(
                      //topLeft: Radius.circular(15),
                      // bottomLeft: Radius.circular(15),
                      // bottomRight: Radius.circular(15)),
                      ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(children: [
                      SizedBox(height: 3),
                      _firstName(),
                      SizedBox(height: 3),
                      _lastName(),
                      SizedBox(height: 3),
                      _phoneNum(),
                      SizedBox(height: 3),
                      _buildUserEmail(),
                      SizedBox(height: 3),
                      _buildPassword(),
                      SizedBox(height: 3),
                      _buildConfirmPassword(),
                    ]),
                  ),
                ),
                SizedBox(height: 3),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                  ),
                  child: new CheckboxListTile(
                    title: Text("Accept terms and condition"),
                    value: _terms,
                    activeColor: Colors.blue[700],
                    onChanged: (bool value) => setState(() => _terms = value),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              return;
                            }

                            _formKey.currentState.save();
                            setState(() {});
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/main');
                    },
                    child: Text(
                      'Already have an account',
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
    );
  }

  void _showSnackBar(String text, String label, Function press) {
    _scaffoldMessenger.currentState.showSnackBar(new SnackBar(
      content: new Text(text),
      // duration: const Duration( ),
      action: SnackBarAction(label: label, onPressed: press),
    ));
  }

  String _userEmail = "";
  String _userPassword = "";
  String fixedrole = "Customer";
  final _emailController = TextEditingController();
  final _firstameController = TextEditingController();
  final _lastameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  onRegisterPressed() {
    //Framework framework = new Framework(
    //   firstName: _firstameController.text,
    //   lastName: _lastameController.text,
    //   phoneNumber: _phoneController.text,
    //   emailAddress: _emailController.text,
    //   password: _passwordController.text,
    //   role: fixedrole,
    // );
    //EasyLoading.showSuccess('Registration successful');
    onClearPressed();
    // frameworkController.registerUserFrameworks(_firstameController.text,
    //     _lastameController.text, _emailController.text,_phoneController.text,_passwordController.text,
    //     _confirmPasswordController.text);

    setState(() {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });

    //EasyLoading.dismiss();
  }

  onClearPressed() {
    _firstameController.clear();
    _lastameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  void _validateInputs() {
    if (!_formKey.currentState.validate()) {
      return;
    } else if (!_terms) {
      // EasyLoading.showInfo('Accept terms and conditions');
      // _showSnackBar("Accept terms and conditions", 'Required', () {});
    } else {
      _formKey.currentState.save();
      onRegisterPressed();
    }
  }

  _firstName() {
    return TextFormField(
      controller: _firstameController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        hintText: 'First name',
        icon: Icon(Icons.person),
        // border: OutlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[700]),
        ),
        //border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onSaved: (value) {},
      validator: (value) =>
          value.isEmpty ? 'First name must be provided' : null,
    );
  }

  _lastName() {
    return TextFormField(
      controller: _lastameController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        hintText: 'Last name',
        // border: OutlineInputBorder(),
        icon: Icon(Icons.person),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[700]),
        ),
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onSaved: (value) {},
      validator: (value) => value.isEmpty ? 'Last name must be provided' : null,
    );
  }

  _phoneNum() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        hintText: 'Phone',
        icon: Icon(Icons.phone),
        //border: OutlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[700]),
        ),
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onSaved: (value) {},
      validator: (value) => value.isEmpty ? 'phone numberis needed' : null,
    );
  }

  _buildUserEmail() {
    return TextFormField(
      validator: (value) =>
          EmailValidator.validate(value) ? null : "Invalid Email Address",
      onSaved: (value) {
        _userEmail = value;
      },
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      decoration: InputDecoration(
        icon: Icon(Icons.email),
        alignLabelWithHint: true,
        //border: OutlineInputBorder(),
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        hintText: 'Email',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[700]),
        ),
      ),
    );
  }

  _buildPassword() {
    return TextFormField(
      validator: (value) {
        if (value.trim().isEmpty) {
          return 'Password is required';
        }
        if (value.trim().length < 8) {
          return 'Passwords must be at least 8 characters in length';
        }
        return null;
      },
      onSaved: (value) {
        _userPassword = value;
      },
      keyboardType: TextInputType.visiblePassword,
      controller: _passwordController,
      obscureText: _isObscure,
      decoration: InputDecoration(
        icon: Icon(Icons.lock),

        alignLabelWithHint: true,
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        hintText: 'Password',
        // border: OutlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[700]),
        ),
      ),
    );
  }

  _buildConfirmPassword() {
    return TextFormField(
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) {
          return "Password is required";
        }
        if (value != _passwordController.text) {
          return 'password does not match';
        }
        return null;
      },
      onSaved: (value) {
        _userPassword = value;
      },
      keyboardType: TextInputType.visiblePassword,
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        //border: OutlineInputBorder(),
        icon: Icon(Icons.lock),
        alignLabelWithHint: true,
        // suffixIcon: IconButton(
        //   icon: Icon(
        //     _isObscure ? Icons.visibility : Icons.visibility_off,
        //     color: Colors.grey,
        //   ),
        //   onPressed: () {
        //     setState(() {
        //       _isObscure = !_isObscure;
        //     });
        //   },
        // ),
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        hintText: 'Confirm password',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[700]),
        ),
      ),
    );
  }

  takeShot(mCtx) {
    return showDialog(
        context: mCtx,
        builder: (con) {
          return SimpleDialog(
            title: Center(
              child: Text('Upload profile Image'),
            ),
            children: [
              SimpleDialogOption(
                  child: Center(child: Text('Capture with Camera')),
                  onPressed: () {
                    pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  }),
              SimpleDialogOption(
                  child: Center(child: Text('Select from gallery')),
                  onPressed: () {
                    pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              SimpleDialogOption(
                child: Center(child: Text('Cancel')),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }
}
