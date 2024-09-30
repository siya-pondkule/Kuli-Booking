import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  // Use a late variable to hold the context safely
  late BuildContext _snackBarContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save the context for future use
    _snackBarContext = context;
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(_snackBarContext).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        if ((value ?? '').isEmpty) {
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
      // Check file size (Optional: 5 MB limit)
      const int maxFileSizeInBytes = 5 * 1024 * 1024; // 5 MB limit
      final fileSize = await image.length();

      if (fileSize > maxFileSizeInBytes) {
        _showSnackBar('File is too large. Please select a file smaller than 5 MB.');
        return;
      }

      // Check if the selected file is either a .jpg or .png
      if (image.name.endsWith('.jpg') || image.name.endsWith('.png')) {
        if (kIsWeb) {
          Uint8List imageBytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = imageBytes;
            _selectedImage = null; // Reset the file for web
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _selectedImageBytes = null; // Reset the bytes for mobile
          });
        }
      } else {
        _showSnackBar('Please select a JPG or PNG image.');
      }
    }
  }

  Future<String> _uploadImageToStorage(String userId) async {
    if (_selectedImageBytes == null && _selectedImage == null) {
      throw Exception('No image selected for upload');
    }

    try {
      final Reference storageRef = FirebaseStorage.instance.ref().child('kuli/$userId.jpg');

      if (kIsWeb && _selectedImageBytes != null) {
        await storageRef.putData(_selectedImageBytes!);
      } else if (_selectedImage != null) {
        await storageRef.putFile(_selectedImage!);
      }

      String downloadUrl = await storageRef.getDownloadURL();
      print("Image uploaded, URL: $downloadUrl");
      return downloadUrl;      // Return the download URL
    } catch (e) {
      _showSnackBar('Image upload failed: $e');
      return '';
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String userId = userCredential.user!.uid;
        print("User created with ID: $userId");

        // Validate Date of Birth
        DateTime? dob;
        try {
          dob = DateTime.parse(_dobController.text.trim());
        } catch (e) {
          _showSnackBar("Invalid Date Format. Please use YYYY-MM-DD.");
          return;
        }

        // Upload image and get URL
        String profileImageUrl = await _uploadImageToStorage(userId);
        print("Profile image uploaded: $profileImageUrl");

        // Prepare data for Firestore
        Map<String, dynamic> kuliData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'experience': _experienceController.text.trim(),
          'dob': Timestamp.fromDate(dob),
          'station': _stationController.text.trim(),
          'stationId': _stationIdController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'profileImage': profileImageUrl,
        };

        await FirebaseFirestore.instance.collection('kuli').doc(userId).set(kuliData);
        print("Kuli data saved to Firestore");

        // Navigate to login screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KuliLogin()));
      } catch (e) {
        _showSnackBar('Registration failed: $e');
      }
    }
  }
}
