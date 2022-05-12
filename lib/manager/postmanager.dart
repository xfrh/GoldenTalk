import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../service/firestore_service.dart';
import '../service/models/post_model.dart';

class PostManager extends ChangeNotifier {
  final _api = Api('Posts');

  List<Post> PostModels;

  // Future<List<Post>> fetchCalls() async {
  //   var result = await _api.getDataCollection();
  //   PostModels = result.documents
  //       .map((doc) => Post.fromMap(doc.data, doc.documentID))
  //       .toList();
  // }

  Stream<QuerySnapshot> fetchCallsAsStream() {
    return _api.streamDataCollection();
  }

  Future<Post> getCallById(String id) async {
    var doc = await _api.getDocumentById(id);
    return Post.FromSnapShot(doc);
  }

  Future removeCall(String id) async {
    await _api.removeDocument(id);
    return;
  }

  Future updateCall(Post data, String id) async {
    await _api.updateDocument(data.toJson(), id);
    return;
  }

  // Future saveMockData(String uid) async {
  //   for (int i = 0; i < storiesMockData.length; i++) {
  //     StoriesModel _story = storiesMockData[i];
  //     Post _post = Post(DateTime.now().millisecondsSinceEpoch + i * 10,
  //         _story.name, _story.time, uid, _story.profileImageUrl);
  //     _post.imgUrl = _story.storyImageUrl;
  //     await addCall(_post);
  //   }
  // }

  Future<String> addCall(Post data) async {
    try {
      var result = await _api.addDocument(data.toJson());
      return result.documentID;
    } catch (e) {
      print(e);
    }
  }
}
