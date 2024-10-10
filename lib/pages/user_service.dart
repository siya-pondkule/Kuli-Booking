import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to save FCM token
  Future<void> saveFcmToken(String travelerId) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Update the user's document with the FCM token
        await _firestore.collection('users').doc(travelerId).update({
          'fcm_token': token,
        });
      }
    } catch (e) {
      print("Error saving FCM token: $e");
    }
  }

  // Method to get user data
  Future<DocumentSnapshot?> getUserData(String travelerId) async {
    try {
      return await _firestore.collection('users').doc(travelerId).get();
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  // Method to update user profile
  Future<void> updateUserProfile(String travelerId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(travelerId).update(data);
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  // Method to delete user
  Future<void> deleteUser(String travelerId) async {
    try {
      await _firestore.collection('users').doc(travelerId).delete();
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
