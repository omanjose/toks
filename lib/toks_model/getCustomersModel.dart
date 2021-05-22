// To parse this JSON data, do
//
//     final getCustomer = getCustomerFromJson(jsonString);

import 'dart:convert';

GetCustomer getCustomerFromJson(String str) => GetCustomer.fromJson(json.decode(str));

String getCustomerToJson(GetCustomer data) => json.encode(data.toJson());

class GetCustomer {
    GetCustomer({
        this.responseCode,
        this.message,
        this.responseData,
    });

    int responseCode;
    String message;
    List<ResponseDatum> responseData;

    factory GetCustomer.fromJson(Map<String, dynamic> json) => GetCustomer(
        responseCode: json["responseCode"],
        message: json["message"],
        responseData: List<ResponseDatum>.from(json["responseData"].map((x) => ResponseDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "responseCode": responseCode,
        "message": message,
        "responseData": List<dynamic>.from(responseData.map((x) => x.toJson())),
    };
}

class ResponseDatum {
    ResponseDatum({
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

    factory ResponseDatum.fromJson(Map<String, dynamic> json) => ResponseDatum(
        id: json["id"],
        role: Role.fromJson(json["role"]),
        firstName: json["firstName"],
        lastName: json["lastName"],
        createdOn: DateTime.parse(json["createdOn"]),
        dob: json["dob"],
        emailAddress: json["emailAddress"],
        phoneNumber: json["phoneNumber"] == null ? null : json["phoneNumber"],
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
        "phoneNumber": phoneNumber == null ? null : phoneNumber,
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
    Name name;
    Description description;

    factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: nameValues.map[json["name"]],
        description: descriptionValues.map[json["description"]],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": nameValues.reverse[name],
        "description": descriptionValues.reverse[description],
    };
}

enum Description { THIS_IS_THE_USER_OF_THE_APPLICATION }

final descriptionValues = EnumValues({
    "This is the user of the application": Description.THIS_IS_THE_USER_OF_THE_APPLICATION
});

enum Name { CUSTOMER }

final nameValues = EnumValues({
    "CUSTOMER": Name.CUSTOMER
});

class EnumValues<T> {
    Map<String, T> map;
    Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        if (reverseMap == null) {
            reverseMap = map.map((k, v) => new MapEntry(v, k));
        }
        return reverseMap;
    }
}
