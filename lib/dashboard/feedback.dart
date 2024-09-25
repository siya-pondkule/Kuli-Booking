import 'package:flutter/material.dart'; 


class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Transactions',
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
      child: Text('Feedaback Content Here'), 
    );
  }
}
