import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kuli_dashboard.dart'; // Import the Kuli Dashboard screen

class KuliProfile extends StatefulWidget {
  const KuliProfile({super.key});

  @override
  _KuliProfileState createState() => _KuliProfileState();
}

class _KuliProfileState extends State<KuliProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      await _getUserData(_currentUser!.uid);
    }
  }

  Future<void> _getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('kuli')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?; // Store the user data
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    // After signing out, navigate to the Kuli Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const KuliDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuli Profile'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut, // Sign out on button press
          ),
        ],
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image at the top
                  if (_userData?['imageUrl'] != null && _userData!['imageUrl'].isNotEmpty)
                    Image.network(
                      '${_userData!['imageUrl']}?time=${DateTime.now().millisecondsSinceEpoch}', // Prevent cache
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: ${error.toString()}'); // Log the detailed error
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300], // Placeholder color
                      child: const Center(
                        child: Text(
                          'No Image Available',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20), // Space between image and card

                  // Profile details in a Card for a cleaner look
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 10,
                        shadowColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileDetail('Name:', _userData?['name']),
                              _buildProfileDetail('Email:', _userData?['email']),
                              _buildProfileDetail('Phone:', _userData?['phone']),
                              _buildProfileDetail('Address:', _userData?['address']),
                              _buildProfileDetail('Experience:', _userData?['experience']),
                              _buildProfileDetail('Date of Birth:', _formatDateOfBirth(_userData?['dob'])),
                              _buildProfileDetail('Station:', _userData?['station']),
                              _buildProfileDetail('Station ID:', _userData?['stationId']),
                              _buildProfileDetail('Age:', _userData?['age']?.toString()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDateOfBirth(dynamic dob) {
    if (dob is Timestamp) {
      return dob.toDate().toString(); // Convert Timestamp to Date
    } else if (dob is String) {
      return dob; // Return the string as is
    } else {
      return 'N/A'; // Fallback if dob is null or of unexpected type
    }
  }

  Widget _buildProfileDetail(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value ?? 'N/A', textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
