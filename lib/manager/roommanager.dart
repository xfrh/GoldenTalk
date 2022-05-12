import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../service/firestore_service.dart';

class Room {
  String roomId;
  String name;
  String type;
  List<String> members;

  Room({this.name, this.type, this.members});

  Room.fromMap(Map snapshot, String id)
      : roomId = id ?? '',
        name = snapshot['name'] ?? '',
        type = snapshot['type'] ?? '',
        members = snapshot['members'] ?? '';

  Room.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    members = json['members'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['members'] = this.members;
    return data;
  }
}

class RoomManager extends ChangeNotifier {
  final _api = Api('Rooms');

  List<Room> roomModels;

  Future<List<Room>> fetchCalls() async {
    var result = await _api.getDataCollection();
    roomModels = result.documents
        .map((doc) => Room.fromMap(doc.data, doc.documentID))
        .toList();
    return roomModels;
  }

  Stream<QuerySnapshot> fetchCallsAsStream() {
    return _api.streamDataCollection();
  }

  Future<Room> getCallById(String id) async {
    var doc = await _api.getDocumentById(id);
    return Room.fromMap(doc.data, doc.documentID);
  }

  Future removeCall(String id) async {
    await _api.removeDocument(id);
    return;
  }

  Future updateCall(Room data, String id) async {
    await _api.updateDocument(data.toJson(), id);
    return;
  }

  Future<String> addRoom(Room data) async {
    var result = await _api.addDocument(data.toJson());
    return result.documentID;
  }
}
