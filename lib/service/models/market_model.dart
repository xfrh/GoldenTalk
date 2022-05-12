import 'package:firebase_database/firebase_database.dart';

class Stock{
  String id;
  String symbol;
  String name;
  String last;
  String chgPercent;
  String chg;
  String high;
  String low;
  String rating;
 Stock({this.id,this.symbol,this.name,this.last,this.chgPercent,this.chg,this.high,this.low,this.rating});

 Stock.fromSnapshot(DataSnapshot snapshot) :
    id = snapshot.key,
    name = snapshot.value["name"],
    symbol = snapshot.value["symbol"],
    last = snapshot.value["last"],
    chgPercent = snapshot.value["chgPercent"],
    high= snapshot.value['high'],
    low = snapshot.value['low'],
    rating = snapshot.value['rating'];
   

 Stock.fromMap(Map<String, dynamic> json,String documentId) :
        id = documentId ?? '',
        symbol = json['symbol'] ?? '',
         name = json['name'] ?? '',
        last = json['last'] ?? '',
        chgPercent=json['chgPercent'] ?? '',
        chg=json['chg'],
        high=json['high'],
        low=json['low'],
        rating=json['rating'];
      
 Stock.fromJson(Map<String, dynamic> json) {
    id=json['id'];
    symbol = json['symbol'];
    name = json['name'];
    last=json['last'];
    chgPercent = json['chgPercent'];
    chg = json['chg'];
    high = json['high'];
    low = json['low'];
    rating = json['rating'];
   
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id']=this.id;
    data['symbol'] = this.symbol;
    data['last'] = this.last;
    data['chgPercent'] = this.chgPercent;
    data['chg'] = this.chg;
    data['high'] = this.high;
    data['low'] = this.low;
    data['rating'] = this.rating;
    return data;
  }
}

