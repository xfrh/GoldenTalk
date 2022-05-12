import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String postId;
  String title;
  String subtitle;
  String thumb;
  String uid;
  String author;
  String imgUrl;
  String chart;
  String videoUrl;
  String body;
  int date;
  Map<String, String> charts;
  Post();

  Post.FromSnapShot(DocumentSnapshot snapshot) {
    postId = snapshot.documentID;
    title = snapshot['title'];
    subtitle = snapshot['subtitle'];
    thumb = snapshot['thumb'];
    author = snapshot['author'];
    imgUrl = snapshot['imgUrl'];
    chart = snapshot['chart'];
    videoUrl = snapshot['videoUrl'];
    body = snapshot['body'].replaceAll("\\n", "\n");
    date = snapshot['date'];
    uid = snapshot['uid'];
    charts = snapshot['charts'] == null ? null : Map.from(snapshot['charts']);
  }

  toJson() {
    return {
      "title": title,
      "subtitle": subtitle,
      "thumb": thumb,
      "author": author,
      "imgUrl": imgUrl,
      "chart": chart,
      "videoUrl": videoUrl,
      "body": body,
      "date": date,
      "uid": uid,
      "charts": charts,
    };
  }
}
