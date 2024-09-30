import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfile({super.key, required this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _experienceController;
  late TextEditingController _dobController;
  late TextEditingController _stationController;
  late TextEditingController _stationIdController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _addressController = TextEditingController(text: widget.userData['address']);
    _experienceController = TextEditingController(text: widget.userData['experience']);
    _dobController = TextEditingController(text: widget.userData['dob'].toDate().toString().split(' ')[0]);
    _stationController = TextEditingController(text: widget.userData['station']);
    _stationIdController = TextEditingController(text: widget.userData['stationId']);
    _ageController = TextEditingController(text: widget.userData['age'].toString());
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _auth.currentUser;

        Map<String, dynamic> updatedData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'experience': _experienceController.text.trim(),
          'dob': DateTime.parse(_dobController.text.trim()),
          'station': _stationController.text.trim(),
          'stationId': _stationIdController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
        };

        await _firestore.collection('kuli').doc(user!.uid).update(updatedData);
        Navigator.pop(context); // Go back to the profile page
      } catch (e) {
        print('Failed to update profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_nameController, 'Name'),
                _buildTextField(_emailController, 'Email'),
                _buildTextField(_phoneController, 'Phone'),
                _buildTextField(_addressController, 'Address'),
                _buildTextField(_experienceController, 'Experience'),
                _buildTextField(_dobController, 'Date of Birth (YYYY-MM-DD)'),
                _buildTextField(_stationController, 'Station'),
                _buildTextField(_stationIdController, 'Station ID'),
                _buildTextField(_ageController, 'Age'),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _updateProfile, child: const Text('Update')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
