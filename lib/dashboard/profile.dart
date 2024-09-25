import 'package:flutter/material.dart'; 
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
        backgroundColor: Colors.white, 
        elevation: 0, 
      ),
      body: SafeArea(child: _buildUI()), 
    );
  }

  Widget _buildUI() {
    return const Center(
      child: Text('Profile Content Here'), 
    );
  }
}
