import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String firstName;
  String lastName;
  String password;
  String emailAddress;
  String phoneNumber;
  String profilePhoto;
  String role;
  String securityKey;
  String dob;
  String objectId;

  User(
      {this.firstName,
      this.lastName,
      this.password,
      this.emailAddress,
      this.dob,
      this.phoneNumber,
      this.profilePhoto,
      this.role,
      this.objectId,
      this.securityKey});

  factory User.fromJson(Map<String, dynamic> json) => User(
        firstName: json['firstName'],
        lastName: json['lastName'],
        password: json['password'],
        emailAddress: json['emailAddress'],
        phoneNumber: json['phoneNumber'],
        profilePhoto: json['profilePhoto'],
        role: json['role'],
        securityKey: json['securityKey'],
        dob: json['dob'],
        objectId: json['objectId'],
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'emailAddress': emailAddress,
        'dob': dob,
        'phoneNumber': phoneNumber,
        'role': role,
        'profilePhoto': profilePhoto,
        'securityKey': securityKey,
      };

  String get initials {
    final name1 = firstName.split('');
    final name2 = lastName.split('');
    name1[0].substring(0, 1);
    name2[0].substring(0, 1);
    return 'name1 + name2'.toString().toUpperCase();
  }
}
