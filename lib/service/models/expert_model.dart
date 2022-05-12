import 'package:cloud_firestore/cloud_firestore.dart';

class Expert {
  int date;
  String uid;
  String name;
  String email;
  String avator;
  String expertID;
  String description;
  String paypalUrl;
  int followers;
  List<String> portfolios;
  List<String> skills;
  List<String> refers;
  List<String> members;

  Expert(
      {this.date,
      this.uid,
      this.name,
      this.email,
      this.avator,
      this.description,
      this.paypalUrl});

  Expert.fromSnapShot(DocumentSnapshot snapshot) {
    date = snapshot['date'];
    followers = snapshot['followers'];
    uid = snapshot['uid'];
    name = snapshot['name'];
    email = snapshot['email'];
    avator = snapshot['avator'];
    expertID = snapshot.documentID;
    description = snapshot['description'];
    paypalUrl = snapshot['paypalUrl'];
    portfolios = List.from(snapshot['portfolios']);
    skills = List.from(snapshot['skills']);
    refers = List.from(snapshot['refers']);
    members = List.from(snapshot['members']);
  }

  toJson() {
    return {
      "date": date,
      "followers": followers,
      "uid": uid,
      "name": name,
      "email": email,
      "avator": avator,
      "expertID": expertID,
      "description": description,
      "paypalUrl": paypalUrl,
      "portfolios": portfolios,
      "skills": skills,
      "refers": refers,
      "members": members,
    };
  }
}
