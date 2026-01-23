import 'package:flutter_agent_pupau/services/json_parse_service.dart';

class Conversation {
  String id;
  DateTime createdAt;
  DateTime? lastQueryTime;
  String title;
  String token;
  String userId;
  String assistantId;
  int queryCount;
  int? rating;
  String comment;
  String userName;
  String userSurname;
  //Frontend only
  bool hasTempTitle = false;

  Conversation({
    required this.id,
    required this.createdAt,
    this.lastQueryTime,
    required this.title,
    required this.token,
    required this.userId,
    required this.assistantId,
    required this.queryCount,
    this.rating,
    required this.comment,
    required this.userName,
    required this.userSurname,
  });

  factory Conversation.fromMap(Map<String, dynamic> json) => Conversation(
    id: getString(json["id"]),
    createdAt: getDateTime(json["createdAt"]),
    lastQueryTime: json["lastQueryTimestamp"] != null
        ? getDateTime(json["lastQueryTimestamp"])
        : null,
    title: getString(json["title"]),
    token: getString(json["token"]),
    userId: getString(json["userId"]),
    assistantId: getString(json["chatBotId"]),
    queryCount: getInt(json["queryCount"]),
    rating: json["reaction"]?["rating"] != null
        ? getInt(json["reaction"]?["rating"])
        : null,
    comment: getString(json["reaction"]?["comment"]),
    userName: getString(json["user"]?["name"]),
    userSurname: getString(json["user"]?["surname"]),
  );
}

enum ConversationVisibility { public, loggedUsers, myOrganization }
