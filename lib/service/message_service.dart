import 'package:firebase_messaging/firebase_messaging.dart';
class MessageService {
  FirebaseMessaging firebaseMessaging;
  String phone_token;
  static MessageService _instance;
  static Future<MessageService> getInstance() async {
    if (_instance == null) {
      _instance = MessageService();
    }
    return _instance;
  }

  MessageService() {
    firebaseMessaging = new FirebaseMessaging();
      firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called: $message');

      },
      onResume: (Map<String, dynamic> message) {
        print('onResume called: $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch called: $message');
      },
    );
    firebaseMessaging.getToken().then((token) {
    //  print('FCM Token: $token');
      phone_token=token;
    });
    firebaseMessaging.subscribeToTopic('Notification');
  }
}
