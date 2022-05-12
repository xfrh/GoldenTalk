import 'package:cloud_firestore/cloud_firestore.dart';

class Notify{
  String noticeID;
  String roomId;
  String uid;
  String message;
  String displayName;
  String imageUrl;
  String email;
   int date;

  Notify({this.roomId,this.message});
  Notify.fromSnapShot(DocumentSnapshot snapshot){
    this.noticeID=snapshot.documentID;
    this.roomId=snapshot.data['roomId'];
    this.message=snapshot.data['message'];
    this.displayName=snapshot.data['displayName'];
    this.imageUrl=snapshot.data['imageUrl'];
    this.date=snapshot.data['date'];
    this.email=snapshot.data['email'];
    this.uid=snapshot.data['uid'];
   
  }
toJson() {
    return {
      "noticeID" : noticeID,
      "roomId": roomId,
      "message": message,
      "displayName" : displayName,
      "imageUrl" : imageUrl,
      "date" : date,
      "email" : email,
      "uid" : uid,
      
    };
  }


}