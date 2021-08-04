import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  int id;
  String firstName;
  String lastName;
  String password;
  String emailAddress;
  String phoneNumber;
  String profilePhoto;
  Role role;
  String securityKey;
  String dob;

  User(
      {this.id,
      this.firstName,
       this.lastName,
       this.password,
       this.emailAddress,
       this.dob,
       this.phoneNumber,
       this.profilePhoto,
       this.role,
       this.securityKey});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        password: json['password'] as String,
        emailAddress: json['emailAddress'] as String,
        phoneNumber: json['phoneNumber'] as String,
        profilePhoto: json['profilePhoto'] as String,
        role: Role.fromJson(json['role']),
        securityKey: json['securityKey'] as String,
        dob: json['dob'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'emailAddress': emailAddress,
        'dob': dob,
        'phoneNumber': phoneNumber,
        'profilePhoto': profilePhoto,
        'securityKey': securityKey,
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

  factory Role.fromJson(Map<String, dynamic> rolejson) => Role(
        id: rolejson["id"],
        name: rolejson["name"],
        description: rolejson["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
      };
}
