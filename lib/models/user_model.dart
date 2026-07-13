import 'dart:convert';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';

User userFromMap(String str) => User.fromMap(json.decode(str));

String userToMap(User data) => json.encode(data.toMap());

class User {
  String id;
  String? name;
  String? surname;
  String? nickname;
  DateTime? birthDate;
  bool verified;
  String username;
  String language;
  String image;

  User(
      {required this.id,
      this.name,
      this.surname,
      this.nickname,
      this.birthDate,
      required this.verified,
      required this.username,
      required this.language,
      required this.image});

  factory User.fromMap(Map<String, dynamic> json) => User(
      id: getString(json["id"]),
      name: json["name"],
      surname: json["surname"],
      nickname: json["nickname"],
      birthDate: json["birthDate"] == null
          ? null
          : DateTime.tryParse(json["birthDate"] ?? "") ?? DateTime.now(),
      verified: json["verified"] != "NONE",
      username: json["username"] ?? "",
      language: json["language"] ?? "",
      image: json["image"] ?? "",);

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "surname": surname,
        "nickname": nickname,
        "birthDate": birthDate?.toIso8601String(),
        "verified": verified ? "VERIFIED" : "NONE",
        "username": username,
        "language": language,
        "image": image,
      };
}