import 'package:firebase_messaging/firebase_messaging.dart';

class MyFirebaseMessagingService {
  // Handle foreground messages
  void init() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.data}');
      // You can show a dialog or update UI here
    });

    // Handle messages when the app is opened from a terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! ${message.data}');
    });
  }
}
