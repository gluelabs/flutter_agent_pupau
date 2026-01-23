import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageNotifier with ChangeNotifier {
  final List<NotifierMessage> _messages = [];
  String _assistantId = "";
  String _conversationId = "";
  List<NotifierMessage> get messages => _messages;
  String get assistantId => _assistantId;
  String get conversationId => _conversationId;

  void addData(String data, String idMessage) {
    NotifierMessage? message = _messages.firstWhereOrNull(
        (NotifierMessage message) => message.idMessage == idMessage);
    if (message == null) {
      _messages.add(NotifierMessage(message: data, idMessage: idMessage));
    } else {
      message.message = data;
    }
    notifyListeners();
  }

  void setAssistantId(String id) {
    _assistantId = id;
    notifyListeners();
  }

  void setConversationId(String id) {
    _conversationId = id;
    notifyListeners();
  }
}

class NotifierMessage {
  String message;
  String idMessage;

  NotifierMessage({required this.message, required this.idMessage});
}
