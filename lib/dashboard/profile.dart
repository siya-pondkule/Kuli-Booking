import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Call to fetch user data on initialization
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      print("Current User ID: $userId"); // Log the user ID for debugging

      if (userId != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('kuli').doc(userId).get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
            _isLoading = false; // Stop loading
          });
        } else {
          // Create a new user document if it does not exist
          await FirebaseFirestore.instance.collection('kuli').doc(userId).set({
            'name': '',  // Default values
            'email': '',
            'phone': '',
            'address': '',
            'years_of_experience': 0,
            'dob': DateTime.now(), // Default current date
            'photo_url': '', // URL for the profile photo
          });
          print('New user document created.');

          // Fetch the data again after creation
          _fetchUserData(); // Call the function again to get the newly created data
        }
      } else {
        throw Exception("User is not logged in.");
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (_userData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(userData: _userData!),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _userData!['photo_url'] != null && _userData!['photo_url']!.isNotEmpty
                              ? NetworkImage(_userData!['photo_url'])
                              : const NetworkImage('https://via.placeholder.com/150'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileDetail('Name', _userData!['name']),
                      _buildProfileDetail('Email', _userData!['email']),
                      _buildProfileDetail('Phone', _userData!['phone']),
                      _buildProfileDetail('Address', _userData!['address']),
                      _buildProfileDetail('Years of Experience', _userData!['years_of_experience']),
                      _buildProfileDetail('Date of Birth', (_userData!['dob'] as Timestamp).toDate().toLocal().toString().split(' ')[0]),
                    ],
                  ),
                )
              : const Center(child: Text('No user data available')),
    );
  }

  Widget _buildProfileDetail(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text('$label: ${value ?? "N/A"}', style: const TextStyle(fontSize: 20)),
    );
  }
}
