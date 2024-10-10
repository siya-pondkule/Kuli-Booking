import 'package:book_my_kuli/dashboard/kuli_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'kuli_register.dart';
import 'forgot_password.dart'; // Import the new Forgot Password page

class KuliLogin extends StatefulWidget {
  const KuliLogin({super.key});

  @override
  State<KuliLogin> createState() => _KuliLoginState();
}

class _KuliLoginState extends State<KuliLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Book My Kuli',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
        ),
      ),
      body: SafeArea(
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            _circularImage(),
            const SizedBox(height: 20),
            _loginForm(),
            const SizedBox(height: 20),
            _loginButton(context),
            const SizedBox(height: 10),
            _signupButton(context),
            const SizedBox(height: 10),
            _forgotPasswordText(context),
            const SizedBox(height: 50), // Added padding for better spacing
          ],
        ),
      ),
    );
  }

  Widget _circularImage() {
    return const CircleAvatar(
      radius: 50,
      backgroundImage: AssetImage('assets/kuli.jpeg'), // Ensure the image path is correct
    );
  }

  Widget _loginForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email), // Add email icon
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock), // Add password icon
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your password';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.redAccent, // Themed button color
        elevation: 5,
      ),
      child: const Text('Sign In', style: TextStyle(fontSize: 18)),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Navigate to the dashboard upon successful login
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KuliDashboard()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    }
  }

  Widget _signupButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const KuliRegister()));
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.greenAccent, // Themed sign up button color
        elevation: 5,
      ),
      child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _forgotPasswordText(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
      },
      child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue, fontSize: 16)),
    );
  }
}
