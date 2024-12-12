import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatRoomId;
  String? lastMsg;
  Map<String, dynamic>? participant;
  DateTime? chatCreatedOn;
  List<dynamic>? users;

  ChatRoomModel(
      {this.chatRoomId,
      this.participant,
      this.lastMsg,
      this.chatCreatedOn,
      this.users});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map["chatRoomId"] ?? "";
    participant = map["participant"] ?? "";
    lastMsg = map["lastMsg"] ?? "";
    chatCreatedOn = (map['chatCreatedOn'] as Timestamp?)?.toDate();
    users = map["users"] ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "participant": participant,
      "lastMsg": lastMsg,
      "chatCreatedOn":
          chatCreatedOn != null ? Timestamp.fromDate(chatCreatedOn!) : null,
      "users": users,
    };
  }
}
