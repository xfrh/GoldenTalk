import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../service/firestore_service.dart';
import '../service/models/expert_model.dart';

class ExpertManager extends ChangeNotifier {
  final _api = Api('Experts');

  Stream<QuerySnapshot> fetchCallsAsStream() {
    return _api.streamDataCollection();
  }

  Future<List<Expert>> getExperts() async {
    var docs = await _api.getAllDoucments();
    if (docs != null && docs.length > 0) {
      final _lst = List<Expert>();
      docs.forEach((element) {
        _lst.add(Expert.fromSnapShot(element));
      });
      return _lst;
    }
    return null;
  }

  Future<Expert> getExpertByUid(String uid) async {
    var doc = await _api.getSelectedItem('uid', uid);
    return doc == null ? null : Expert.fromSnapShot(doc.documents[0]);
  }

  Future<Expert> getExpertBYfield(String field, String fieldValue) async {
    var doc = await _api.getSelectedItem(field, fieldValue);
    return doc == null ? null : Expert.fromSnapShot(doc.documents[0]);
  }

  Future removeExpert(String expertID) async {
    await _api.removeDocument(expertID);
    return;
  }

  Future updateExpert(Expert data, String expertID) async {
    await _api.updateDocument(data.toJson(), expertID);
    return;
  }

  Future<String> addExpert(Expert data) async {
    var result = await _api.addDocument(data.toJson());
    return result.documentID;
  }
}
