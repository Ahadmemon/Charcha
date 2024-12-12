import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? msgId;
  String? text;
  String? sender;
  bool? seen;
  DateTime? createdOn;

  MessageModel({this.text, this.sender, this.seen, this.createdOn, this.msgId});

  MessageModel.fromMap(Map<String, dynamic> map) {
    text = map["text"] ?? "";
    sender = map["sender"] ?? "";
    seen = map["seen"] ?? "";
    createdOn = (map['createdOn'] != null
        ? (map['createdOn'] as Timestamp).toDate()
        : null ?? "") as DateTime?;
    msgId = map["msgId"] ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "sender": sender,
      "seen": seen,
      "createdOn": createdOn != null ? Timestamp.fromDate(createdOn!) : null,
      "msgId": msgId
    };
  }
}
