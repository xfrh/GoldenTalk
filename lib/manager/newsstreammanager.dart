import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../service/firestore_service.dart';
import '../service/models/newsstream_model.dart';

class NewsStreamManager extends ChangeNotifier {
  final _api = Api('NewsStream');

  Stream<QuerySnapshot> fetchCallsAsStream() {
    return _api.streamDataCollection();
  }

  Future<List<NewsStream>> getExperts() async {
    var docs = await _api.getAllDoucments();
    if (docs != null && docs.length > 0) {
      final _lst = List<NewsStream>();
      docs.forEach((element) {
        _lst.add(NewsStream.fromSnapShot(element));
      });
      return _lst;
    }
    return null;
  }

  Future<NewsStream> getExpertByUid(String uid) async {
    var doc = await _api.getSelectedItem('uid', uid);
    return doc == null ? null : NewsStream.fromSnapShot(doc.documents[0]);
  }

  Future<NewsStream> getExpertBYfield(String field, String fieldValue) async {
    var doc = await _api.getSelectedItem(field, fieldValue);
    return doc == null ? null : NewsStream.fromSnapShot(doc.documents[0]);
  }

  Future removeNewsStream(String streamID) async {
    await _api.removeDocument(streamID);
    return;
  }

  Future updateNewsStream(NewsStream data, String streamID) async {
    await _api.updateDocument(data.toJson(), streamID);
    return;
  }

  Future<String> addNewsStream(NewsStream data) async {
    var result = await _api.addDocument(data.toJson());
    return result.documentID;
  }
}
