import 'dart:convert';

class User {
  String firstName = "";
  String lastName = "";
  String password = "";
  String emailAddress = "";
  String phoneNumber = "";
  String profilePhoto = "";
  String role = "";
  String securityKey = "";
  String dob = "";
  String objectId = "";

  User();

  // User(
  //     {this.firstName,
  //     this.lastName,
  //     this.password,
  //     this.emailAddress,
  //     this.dob,
  //     this.phoneNumber,
  //     this.profilePhoto,
  //     this.role,
  //     this.objectId,
  //     this.securityKey});

  // User(fname, lname, password, email, dob, phone, photo, role, objId, seckey) {
  //   this.firstName = fname;
  //   this.lastName = lname;
  //   this.password = password;
  //   this.emailAddress = email;
  //   this.dob = dob;
  //   this.phoneNumber = phone;
  //   this.profilePhoto = photo;
  //   this.role = role;
  //   this.objectId = objId;
  //   this.securityKey = seckey;
  // }

  factory User.fromJson(Map<String, dynamic> json) {
    User user = new User();

    user.firstName = json['firstName'];
    user.lastName = json['lastName'];
    user.password = json['password'];
    user.emailAddress = json['emailAddress'];
    user.phoneNumber = json['phoneNumber'];
    user.profilePhoto = json['profilePhoto'];
    user.role = json['role'];
    user.securityKey = json['securityKey'];
    user.dob = json['dob'];
    user.objectId = json['objectId'];

    return user;
  }

  // factory User.fromJson(Map<String, dynamic> json) => User(
  //       firstName: json['firstName'],
  //       lastName: json['lastName'],
  //       password: json['password'],
  //       emailAddress: json['emailAddress'],
  //       phoneNumber: json['phoneNumber'],
  //       profilePhoto: json['profilePhoto'],
  //       role: json['role'],
  //       securityKey: json['securityKey'],
  //       dob: json['dob'],
  //       objectId: json['objectId'],
  //     );

  // factory User.fromJson(Map<String, dynamic> json) => User(
  //       firstName: json['firstName'],
  //       lastName: json['lastName'],
  //       password: json['password'],
  //       emailAddress: json['emailAddress'],
  //       phoneNumber: json['phoneNumber'],
  //       profilePhoto: json['profilePhoto'],
  //       role: json['role'],
  //       securityKey: json['securityKey'],
  //       dob: json['dob'],
  //       objectId: json['objectId'],
  //     );

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
