// To parse this JSON data, do
//
//     final userById = userByIdFromJson(jsonString);

import 'dart:convert';

UserById userByIdFromJson(String str) => UserById.fromJson(json.decode(str));

String userByIdToJson(UserById data) => json.encode(data.toJson());

class UserById {
    UserById({
        this.responseCode,
        this.message,
        this.responseData,
    });

    int responseCode;
    String message;
    ResponseData responseData;

    factory UserById.fromJson(Map<String, dynamic> json) => UserById(
        responseCode: json["responseCode"],
        message: json["message"],
        responseData: ResponseData.fromJson(json["responseData"]),
    );

    Map<String, dynamic> toJson() => {
        "responseCode": responseCode,
        "message": message,
        "responseData": responseData.toJson(),
    };
}

class ResponseData {
    ResponseData({
        this.id,
        this.role,
        this.firstName,
        this.lastName,
        this.createdOn,
        this.dob,
        this.emailAddress,
        this.phoneNumber,
        this.profilePhotoUrl,
        this.profilePhotoFormat,
        this.isDisabled,
    });

    int id;
    Role role;
    String firstName;
    String lastName;
    DateTime createdOn;
    dynamic dob;
    String emailAddress;
    String phoneNumber;
    dynamic profilePhotoUrl;
    dynamic profilePhotoFormat;
    bool isDisabled;

    factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
        id: json["id"],
        role: Role.fromJson(json["role"]),
        firstName: json["firstName"],
        lastName: json["lastName"],
        createdOn: DateTime.parse(json["createdOn"]),
        dob: json["dob"],
        emailAddress: json["emailAddress"],
        phoneNumber: json["phoneNumber"],
        profilePhotoUrl: json["profilePhotoUrl"],
        profilePhotoFormat: json["profilePhotoFormat"],
        isDisabled: json["isDisabled"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "role": role.toJson(),
        "firstName": firstName,
        "lastName": lastName,
        "createdOn": createdOn.toIso8601String(),
        "dob": dob,
        "emailAddress": emailAddress,
        "phoneNumber": phoneNumber,
        "profilePhotoUrl": profilePhotoUrl,
        "profilePhotoFormat": profilePhotoFormat,
        "isDisabled": isDisabled,
    };
}

class Role {
    Role({
        this.id,
        this.name,
        this.description,
    });

    int id;
    String name;
    String description;

    factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
    };
}