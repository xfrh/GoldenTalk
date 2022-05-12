import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../service/firestore_service.dart';
import '../service/models/video_chat.dart';

class VideoChatManager extends ChangeNotifier {
  final _api = Api('VideoChat');

  Stream<QuerySnapshot> fetchCallsAsStream() {
    return _api.streamDataCollection();
  }

  Future<List<VideoChat>> getVideoChatsByRoomId(String roomId) async {
    final documents = await _api.getSelectedItemsById('roomId', roomId);
    final vidochats = List<VideoChat>();
    if (documents != null && documents.length > 0) {
      documents.forEach((element) {
        vidochats.add(VideoChat.fromSanpShot(element));
      });
    }
    return vidochats;
  }

  Future<VideoChat> getVideoByUid(String uid) async {
    var doc = await _api.getSelectedItem('uid', uid);
    return doc == null ? null : VideoChat.fromSanpShot(doc.documents[0]);
  }

  Future<VideoChat> getVideoChatBYfield(String field, String fieldValue) async {
    var doc = await _api.getSelectedItem(field, fieldValue);
    return doc == null ? null : VideoChat.fromSanpShot(doc.documents[0]);
  }

  Future removeVideoChat(String messageId) async {
    await _api.removeDocument(messageId);
    return;
  }

  Future updateVideoChat(VideoChat data, String messageId) async {
    await _api.updateDocument(data.toJson(), messageId);
    return;
  }

  Future<String> addVideoChat(VideoChat data) async {
    var result = await _api.addDocument(data.toJson());
    return result.documentID;
  }
}
