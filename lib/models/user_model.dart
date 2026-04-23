// lib/models/user_model.dart

import '../enums/app_enums.dart';

class UserModel {
  final String fullName;
  final String email;
  final String password;
  final Gender gender;

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.gender,
  });

  Map<String, String> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'gender': gender.name,
    };
  }

  factory UserModel.fromMap(Map<String, String> map) {
    return UserModel(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      gender: Gender.values.firstWhere(
        (g) => g.name == map['gender'],
        orElse: () => Gender.preferNotToSay,
      ),
    );
  }
}
