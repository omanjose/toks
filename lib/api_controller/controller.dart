import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:project2/toks_model/user.dart';

class Auth extends ChangeNotifier {
  String urlHost = 'http://toks.herokuapp.com';
  final storage = new FlutterSecureStorage();
  bool authenticated = false;
  String token;
  User authenticatedUser;

  get loggedIn {
    return authenticated;
  }

  get framework {
    return authenticatedUser;
  }

  Future<dynamic> signIn(String email, String password) async {
    String myUrl = "$urlHost/api/user/login";
    String token;
    var data;
    try {
      final response = await http.post(Uri.parse(myUrl),
          headers: {'Content-Type': 'application/json'},
          body: {"emailAddress": "$email", "password": "$password"});
      var status = response.body.contains('error');
      // print(response.body.toString());
      if (response.body.isNotEmpty) {
        data = json.decode(response.body);
      }
      token = json.decode(response.toString())['data']['token'];
      if (status) {
        print('data : ${data["error"]}');
      } else {
        print('data : ${data["token"]}');
        //this._setStoredToken(token);
        this._setStoredToken(data['token']);
      }

      print(token);
      authenticated = true;

      //this._setStoredToken(token);
      this.attempt(token: data['token']);

      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  void attempt({token = ''}) async {
    if (token.toString().isNotEmpty) {
      this.token = token;
    }
    if (this.token.toString().isEmpty) {
      return;
    }
    //auth to grab user's information
    try {
      var response =
          await http.get(Uri.parse('/api/user/get-current-user-details'));

      this.authenticated = true;

      this.authenticatedUser =
          User.fromJson(json.decode(response.toString())['data']);
      notifyListeners();
    } catch (e) {
      this._setUnAuthenticated();
      print(e.toString());
      //throw Exception(e.toString());
    }
  }

  void signOut() async {
    try {
      //await http.post(Uri.parse(uri));
      this._setUnAuthenticated();
      notifyListeners();
    } catch (e) {}
  }

  void _setUnAuthenticated() async {
    this.authenticated = false;
    this.authenticatedUser = null;
    await storage.delete(key: 'token');
  }

  void _setStoredToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future registerUser(
    String confrimPassword,
    String email,
    String firstName,
    String lastName,
    String password,
    String phoneNumber,
    String profilePhoto,
    String securityKey,
    String role,
  ) async {
    String myUrl = "$urlHost/api/user/signup";
    final response = await http.post(Uri.parse(myUrl), headers: {
      'Accept': 'application/json'
    }, body: {
      "confirmPassword": "confirmPassword",
      "emailAddress": "email",
      "firstName": "firstName",
      "lastName": "lastName",
      "password": "password",
      "phoneNumber": "phoneNumber",
      "profilePhoto": "profilePhoto",
      "role": "role",
      "securityKey": "securityKey"
    });
    var status = response.body.contains('error');
    var data = json.decode(response.body);
    if (status) {
      print('data : ${data["error"]}');
    } else {
      print('data : ${data["token"]}');
      this._setStoredToken(data['token']);
    }
  }
}
