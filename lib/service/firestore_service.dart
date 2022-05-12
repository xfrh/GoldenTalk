import 'package:cloud_firestore/cloud_firestore.dart';

class Api {
  final Firestore _db = Firestore.instance;
  final String path;
  CollectionReference ref;

  Api(this.path) {
    ref = _db.collection(path);
  }

  Future<bool> checkExist(String field, String name) async {
    final QuerySnapshot result =
        await ref.where(field, isEqualTo: name).limit(1).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents.length == 1;
  }

  Future<QuerySnapshot> getSelectedItem(String field, String name) async {
    final QuerySnapshot result =
        await ref.where(field, isEqualTo: name).limit(1).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents.length == 1 ? result : null;
  }

  Future<List<DocumentSnapshot>> getSelectedItemsById(
      String field, String value) async {
    final QuerySnapshot result =
        await ref.where(field, isEqualTo: value).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents;
  }

  Future<List<DocumentSnapshot>> getAllDoucments() async {
    final QuerySnapshot result = await ref.getDocuments();
    return result.documents;
  }

  Future<QuerySnapshot> getDataCollection() {
    return ref.getDocuments();
  }

  Stream<QuerySnapshot> streamDataCollection() {
    return ref.snapshots();
  }

  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.document(id).get();
  }

  Query getDocumentByRef(String field, String refId) {
    return ref.where(field, isEqualTo: refId);
  }

  Stream<QuerySnapshot> getDataById(int id) {
    return ref.where('id==' + id.toString()).snapshots();
  }

  Future<void> removeDocument(String id) {
    return ref.document(id).delete();
  }

  Future<DocumentReference> addDocument(Map data) {
    return ref.add(data);
  }

  Future<void> updateDocument(Map data, String id) {
    return ref.document(id).updateData(data);
  }
}
