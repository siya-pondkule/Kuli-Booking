import 'package:flutter/material.dart'; 

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Bookings',
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
      child: Text('Booking Content Here'), 
    );
  }
}
