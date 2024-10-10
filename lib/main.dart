import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'pages/loading.dart';
import 'pages/kuli_login.dart';
import 'pages/forgot_password.dart';

// Firebase configuration details
const firebaseConfig = {
  "apiKey": "AIzaSyAABLBBksiKmh72rBTBEzL0Qh1_RD3NUD8",
  "authDomain": "book-my-coolie-82e3c.firebaseapp.com",
  "projectId": "book-my-coolie-82e3c",
  "storageBucket": "book-my-coolie-82e3c.appspot.com",
  "messagingSenderId": "266668166073",
  "appId": "1:266668166073:web:84f260b6f4970f48e00468",
  "measurementId": "G-305ZHE7MN9"
};

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig["apiKey"]!,
      authDomain: firebaseConfig["authDomain"]!,
      projectId: firebaseConfig["projectId"]!,
      storageBucket: firebaseConfig["storageBucket"]!,
      messagingSenderId: firebaseConfig["messagingSenderId"]!,
      appId: firebaseConfig["appId"]!,
      measurementId: firebaseConfig["measurementId"]!,
    ),
  );

  // Set up Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for iOS
  NotificationSettings settings = await messaging.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('User denied permission');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuli App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingPage(),
        '/kuli_login': (context) => const KuliLogin(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
      },
    );
  }
}
