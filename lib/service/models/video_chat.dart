import 'package:cloud_firestore/cloud_firestore.dart';

class VideoChat {
  String messageId;
  String uid;
  String roomId;
  String image;
  String name;
  String lastMessage;
  int date;
  VideoChat();
  VideoChat.fromSanpShot(DocumentSnapshot snapshot) {
    messageId = snapshot.documentID;
    uid = snapshot['uid'];
    roomId = snapshot['roomId'];
    image = snapshot['image'];
    name = snapshot['name'];
    lastMessage = snapshot['lastMessage'];
    date = snapshot['date'];
  }

  toJson() {
    return {
      "messageId": messageId,
      "uid": uid,
      "roomId": roomId,
      "image": image,
      "name": name,
      "lastMessage": lastMessage,
      "date": date,
    };
  }
}
