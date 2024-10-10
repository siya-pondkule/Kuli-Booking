import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // To check if running on web
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'kuli_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // FontAwesome for Icons

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

  late BuildContext _snackBarContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.redAccent, // Make the AppBar red
      ),
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
                  _buildTextField(_nameController, 'Name', TextInputType.name, FontAwesomeIcons.user),
                  const SizedBox(height: 10),
                  _buildTextField(_emailController, 'Email', TextInputType.emailAddress, FontAwesomeIcons.envelope),
                  const SizedBox(height: 10),
                  _buildTextField(_passwordController, 'Password', TextInputType.visiblePassword, FontAwesomeIcons.lock, obscureText: true),
                  const SizedBox(height: 10),
                  _buildTextField(_phoneController, 'Phone', TextInputType.phone, FontAwesomeIcons.phone),
                  const SizedBox(height: 10),
                  _buildTextField(_addressController, 'Address', TextInputType.text, FontAwesomeIcons.addressBook),
                  const SizedBox(height: 10),
                  _buildTextField(_experienceController, 'Experience', TextInputType.text, FontAwesomeIcons.briefcase),
                  const SizedBox(height: 10),
                  _buildTextField(_dobController, 'Date of Birth (YYYY-MM-DD)', TextInputType.datetime, FontAwesomeIcons.calendar),
                  const SizedBox(height: 10),
                  _buildTextField(_stationController, 'Station', TextInputType.text, FontAwesomeIcons.train),
                  const SizedBox(height: 10),
                  _buildTextField(_stationIdController, 'Station ID', TextInputType.text, FontAwesomeIcons.idCard),
                  const SizedBox(height: 10),
                  _buildTextField(_ageController, 'Age', TextInputType.number, FontAwesomeIcons.hashtag),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: const Text('Upload photo of Kuli'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // Make button red
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedImage != null || _selectedImageBytes != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: kIsWeb
                          ? Image.memory(_selectedImageBytes!, height: 150)
                          : Image.file(_selectedImage!, height: 150),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text('Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // Make button red
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType inputType, IconData icon, {bool obscureText = false}) {
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
        prefixIcon: Icon(icon, color: Colors.redAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.redAccent), // Red border when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0), // Red border when focused
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      const int maxFileSizeInBytes = 5 * 1024 * 1024; // 5 MB limit
      final fileSize = await image.length();

      if (fileSize > maxFileSizeInBytes) {
        _showSnackBar('File is too large. Please select a file smaller than 5 MB.');
        return;
      }

      if (image.name.endsWith('.jpg') || image.name.endsWith('.png')) {
        if (kIsWeb) {
          Uint8List imageBytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = imageBytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _selectedImageBytes = null;
          });
        }
      } else {
        _showSnackBar('Please select a JPG or PNG image.');
      }
    }
  }

  Future<String> _uploadImageToStorage(String kuliId) async {
    if (_selectedImageBytes == null && _selectedImage == null) {
      throw Exception('No image selected for upload');
    }

    try {
      final Reference storageRef = FirebaseStorage.instance.ref().child('kuli/$kuliId.jpg');

      if (kIsWeb && _selectedImageBytes != null) {
        await storageRef.putData(_selectedImageBytes!);
      } else if (_selectedImage != null) {
        await storageRef.putFile(_selectedImage!);
      }

      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create the user using email and password
        final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Use the user ID as the document ID
        String kuliId = userCredential.user!.uid;

        // Log the Kuli ID for debugging
        print('Kuli ID: $kuliId');

        // Upload the image and get the URL
        String imageUrl = await _uploadImageToStorage(kuliId);

        // Store the user data in Firestore with kuliId
        await FirebaseFirestore.instance.collection('kuli').doc(kuliId).set({
          'kuliId': kuliId,  // Add the kuliId field here
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'experience': _experienceController.text,
          'dob': Timestamp.fromDate(DateTime.parse(_dobController.text)), // Use Timestamp for the date
          'station': _stationController.text,
          'stationId': _stationIdController.text,
          'age': int.tryParse(_ageController.text), // Convert age to integer
          'imageUrl': imageUrl,
        });

        _showSnackBar('Registration successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KuliLogin()),
        );
      } catch (e) {
        print('Error during registration: $e');
        _showSnackBar('Registration failed: ${e.toString()}');
      }
    }
  }
}
