import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;


class NetworkHandler extends ChangeNotifier {
  String baseUrl = "http://toks.herokuapp.com";

  var log = Logger();
  FlutterSecureStorage storage = FlutterSecureStorage();

  String formatter(String url) {
    return baseUrl + url;
  }

  //Method to fetch from database
  Future get(String url) async {
    String token = await storage.read(key: "token");
    url = formatter(url);
    var response = await http.get(
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

  Future<http.Response> getUserDetails(String url) async {
    String token = await storage.read(key: "token");
    url = formatter(url);
    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      throw Exception("Failed to load data");
    }
  }

 

  //make posts
  Future<http.Response> post(String url, Map<String, String> body) async {
    String token = await storage.read(key: "token");
    url = formatter(url);
    log.d(body);
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

  Future<http.Response> patch(String url, Map<String, String> body) async {
    String token = await storage.read(key: "token");
    url = formatter(url);
    log.d(body);
    var response = await http.patch(
      Uri.parse(url),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode(body),
    );
    return response;
  }

  

  

  Future<http.StreamedResponse> patchImage(String url, String filepath) async {
    String token = await storage.read(key: "token");
    url = formatter(url);
    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath("img", filepath));
    request.headers.addAll(
        {"Content-type": "multipart/form-data", "Authorization": "Bearer $token"});
        //{"Content-type": "application/json", "Authorization": "Bearer $token"});
    var response = request.send();
    return response;
  }

  NetworkImage getImage(String imageName) {
    String url = formatter("/uploads//$imageName.jpg");
    return NetworkImage(url);
  }
}
