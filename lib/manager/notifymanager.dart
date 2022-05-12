import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../service/firestore_service.dart';
import '../service/models/notification_model.dart';

class NotifyManager extends ChangeNotifier {
  final _api = Api('notices');

  Future<bool> checkExist(String roomId) async {
    return _api.checkExist('roomId', roomId);
  }

  Future<Notify> getNoticeByRoomId(String roomId) async {
    var doc = await _api.getSelectedItem('roomId', roomId);
    return doc == null ? null : Notify.fromSnapShot(doc.documents[0]);
  }

  Future<List<Notify>> getNoticesByRoomId(String roomId) async {
    List<Notify> _lst = List<Notify>();
    var result = await _api.getDocumentByRef('roomId', roomId).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((element) {
      _lst.add(Notify.fromSnapShot(element));
    });
    return _lst;
  }

  Future removeNotice(String id) async {
    await _api.removeDocument(id);
    return;
  }

  Future updateNotice(Notify data, String noticeID) async {
    await _api.updateDocument(data.toJson(), noticeID);
    return;
  }

  Future<String> addNotice(Notify data) async {
    var result = await _api.addDocument(data.toJson());
    return result.documentID;
  }
}
