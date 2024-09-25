import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // To check if running on web
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'kuli_login.dart';

class KuliRegister extends StatefulWidget {
  const KuliRegister({super.key});

  @override
  State<KuliRegister> createState() => _KuliRegisterState();
}

class _KuliRegisterState extends State<KuliRegister> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _stationIdController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  File? _selectedImage; 
  Uint8List? _selectedImageBytes;
  String? _profileImageUrl; // Store the image URL after upload

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Register Page',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, 'Name', TextInputType.name),
                  const SizedBox(height: 10),
                  _buildTextField(_emailController, 'Email', TextInputType.emailAddress),
                  const SizedBox(height: 10),
                  _buildTextField(_passwordController, 'Password', TextInputType.visiblePassword, obscureText: true),
                  const SizedBox(height: 10),
                  _buildTextField(_phoneController, 'Phone', TextInputType.phone),
                  const SizedBox(height: 10),
                  _buildTextField(_addressController, 'Address', TextInputType.text),
                  const SizedBox(height: 10),
                  _buildTextField(_experienceController, 'Experience', TextInputType.text),
                  const SizedBox(height: 10),
                  _buildTextField(_dobController, 'Date of Birth (YYYY-MM-DD)', TextInputType.datetime),
                  const SizedBox(height: 10),
                  _buildTextField(_stationController, 'Station', TextInputType.text),
                  const SizedBox(height: 10),
                  _buildTextField(_stationIdController, 'Station ID', TextInputType.text),
                  const SizedBox(height: 10),
                  _buildTextField(_ageController, 'Age', TextInputType.number),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: _uploadImage, child: const Text('Upload photo of Kuli')),
                  const SizedBox(height: 10),
                  if (_selectedImage != null || _selectedImageBytes != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: kIsWeb 
                          ? Image.memory(_selectedImageBytes!, height: 150) 
                          : Image.file(_selectedImage!, height: 150),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _register, child: const Text('Register')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType inputType, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscureText,
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

  Future<void> _uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        // For web, read as bytes
        Uint8List imageBytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = imageBytes;
        });
      } else {
        // For mobile, use a file
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }
  }

  Future<String> _uploadImageToStorage(String userId) async {
    try {
      final Reference storageRef = FirebaseStorage.instance.ref().child('kuli_images/$userId.jpg');
      
      if (kIsWeb && _selectedImageBytes != null) {
        // For web, upload using putData
        await storageRef.putData(_selectedImageBytes!);
      } else if (_selectedImage != null) {
        // For mobile, upload the file directly
        await storageRef.putFile(_selectedImage!);
      }

      // Get the download URL
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Image upload failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      return '';
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Get the user ID of the newly created user
        String userId = userCredential.user!.uid;

        // Upload the profile image and get the URL
        _profileImageUrl = await _uploadImageToStorage(userId);

        // Create a map of the Kuli data
        Map<String, dynamic> kuliData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'experience': _experienceController.text.trim(),
          'dob': DateTime.parse(_dobController.text.trim()), // Ensure correct format
          'station': _stationController.text.trim(),
          'stationId': _stationIdController.text.trim(),
          'age': int.parse(_ageController.text.trim()), // Parse age as int
          'profileImage': _profileImageUrl, // Add image URL
        };

        print("Attempting to save Kuli data to Firestore...");
        // Save Kuli data in Firestore
        await FirebaseFirestore.instance.collection('kuli').doc(userId).set(kuliData);
        print("Kuli data saved successfully!");

        // Navigate to the login screen upon successful registration
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KuliLogin()));
      } catch (e) {
        print('Registration failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
      }
    }
  }
}
