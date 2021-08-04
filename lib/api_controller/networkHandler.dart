import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:project2/toks_model/user.dart';

class NetworkHandler extends ChangeNotifier {
  String baseUrl = "http://toks.herokuapp.com";

  var log = Logger();

  String formatter(String url) {
    return baseUrl + url;
  }

  User userModel = new User();

//Method to delete from database
  Future delete(String url) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String token = _prefs.getString("storage");
    url = formatter(url);
    var response = await http.delete(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.i(response.body); //watch this

      return json.decode(response.body);
    }
    log.i(response.body);
    log.i(response.statusCode);
  }

  //Method to fetch from database
  Future<http.Response> get(String url) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String token = _prefs.getString("storage");
   
    url = formatter(url);
    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
     // notifyListeners();
      return response;
    } else {
       log.i(response.body);
       log.i(response.statusCode);
      throw Exception("Failed to load data");
     
    }
  }

  //make posts
  Future<http.Response> post(String url, Map<String, String> body) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String token = _prefs.getString("storage");
    url = formatter(url);
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode(body),
    );
    return response;
  }

  //make updates
  Future<http.Response> put(String url, Map<String, String> body) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String token = _prefs.getString("storage");
    url = formatter(url);
    var response = await http.put(
      Uri.parse(url),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode(body),
    );

    return response;
  }




  NetworkImage getImage(String imageName) {
    String url = formatter("/uploads//$imageName.jpg");
    return NetworkImage(url);
  }
}
