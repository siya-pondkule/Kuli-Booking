import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'verify_otp.dart'; // Import the OTP verification page
import 'reset_password.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _mobileController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendOtp,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOtp() async {
    String mobileNumber = _mobileController.text.trim();
    if (mobileNumber.isNotEmpty) {
      String formattedNumber = "+91$mobileNumber"; // Assuming India as country code
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: formattedNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-verification (if the user is using the same device)
            await _auth.signInWithCredential(credential);
            // Optionally, navigate to the next page if verification is successful
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
            );
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to verify phone number: ${e.message}')));
          },
          codeSent: (String verId, int? resendToken) {
            verificationId = verId; // Store the verification ID
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VerifyOtpPage(verificationId: verificationId, mobileNumber: formattedNumber)),
            );
          },
          codeAutoRetrievalTimeout: (String verId) {
            verificationId = verId; // Update the verification ID
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending OTP: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your mobile number')));
    }
  }
}
