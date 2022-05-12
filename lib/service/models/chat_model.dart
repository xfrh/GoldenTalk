import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {

  String messageID;
   String roomId;
  String name;
  String message;
  int  date;
  String imageUrl;
  ChatModel({this.name, this.message, this.date, this.imageUrl});
  
  ChatModel.fromSnapShot(DocumentSnapshot snapshot){
    messageID=snapshot.documentID;
    date=snapshot.data['date'];
    roomId=snapshot.data['roomId'];
    name=snapshot.data['name'];
    message=snapshot.data['message'];
    imageUrl=snapshot.data['imageUrl'];
  }
  toJson() {
    return {
      "messageID" : messageID,
      "roomId": roomId,
      "name": name,
      "message" : message,
      "imageUrl" : imageUrl,
      "date" :date,
     
    };
  }

}


