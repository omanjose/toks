import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordRecovery extends StatefulWidget {
  @override
  _PasswordRecoveryState createState() => _PasswordRecoveryState();
}

class _PasswordRecoveryState extends State<PasswordRecovery> {
  final formKey = GlobalKey<FormState>();
  final passwordRecoveryText = TextEditingController();
  String _userEmail;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20, left: 5),
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
                    _emailField(),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState.validate()) {
                                  return;
                                }

                                formKey.currentState.save();
                                setState(() {});
                              },
                              child: Text(
                                'Recover password',
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
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      validator: (value) =>
          EmailValidator.validate(value) ? null : "Invalid Email Address",
      onSaved: (value) {
        _userEmail = value;
      },
      style: GoogleFonts.lato(
        fontSize: 16,
      ),
      keyboardType: TextInputType.emailAddress,
      controller: passwordRecoveryText,
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
          borderSide: BorderSide(color: Colors.blue[700]),
        ),
      ),
    );
  }
}
