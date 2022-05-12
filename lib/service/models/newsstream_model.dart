import 'package:cloud_firestore/cloud_firestore.dart';

class NewsStream {
  String id;
  int date;
  String title;
  List<String> videoUrls;

  NewsStream();

  NewsStream.fromSnapShot(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    date = snapshot['date'];
    title = snapshot['title'];
    videoUrls = snapshot['videoUrls'];
  }

  toJson() {
    return {
      "date": date,
      "title": title,
      "videoUrls": videoUrls,
    };
  }
}
