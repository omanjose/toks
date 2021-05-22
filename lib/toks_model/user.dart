import 'dart:convert';

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
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        password: json['password']as String,
        emailAddress: json['emailAddress']as String,
        phoneNumber: json['phoneNumber']as String,
        profilePhoto: json['profilePhoto']as String,
        role: json['role']as String,
        securityKey: json['securityKey']as String,
        dob: json['dob']as String,
        objectId: json['objectId']as String,
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

  @override
  String toString() {
    return 'User{firstName: $firstName, lastName: $lastName, password: $password,emailAddress: $emailAddress, phoneNumber: $phoneNumber, profilePhoto: $profilePhoto,role: $role, securityKey: $securityKey, objectId: $objectId}';
  }
}

// List<User> userFromJson(String jsonData) {
//   final data = json.decode(jsonData);
//   return List<User>.from(data.map((item) => User.fromJson(item)));
// }

List<User> userFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(User data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
