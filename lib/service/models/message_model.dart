
import 'package:firebase_database/firebase_database.dart';

class Message {
  String messageId;
  String roomId;
  String senderId;
  String senderName;
  String senderpic;
  String content;
  String unread;
  String type;
  int  date;
  Message(
      {
      this.messageId,
      this.roomId,
      this.senderId,
      this.senderName,
      this.date,
      this.senderpic,
      this.content,
      this.unread,
      this.type});

   Message.fromSnapshot(DataSnapshot snapshot) :
    messageId = snapshot.key,
    roomId = snapshot.value["roomId"],
    senderId = snapshot.value["senderId"],
    senderName=snapshot.value['senderName'],
    date = snapshot.value["date"],
    senderpic = snapshot.value['senderpic'],
    unread = snapshot.value['unread'],
    type= snapshot.value['type'];

  Message.fromJson(Map<String, dynamic> json) {
    roomId = json['roomId'];
    messageId = json['messageId'];
    senderId = json['senderId'];
    senderName=json['senderName'];
    date = json['date'];
    senderpic = json['senderpic'];
    content = json['content'];
    unread = json['unread'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = this.roomId;
    data['messageId'] = this.messageId;
    data['senderId'] = this.senderId;
    data['senderName'] =this.senderName;
    data['date'] = this.date;
    data['senderpic'] = this.senderpic;
    data['content'] = this.content;
    data['unread'] = this.unread;
    data['type'] = this.type;
    return data;
  }
}





