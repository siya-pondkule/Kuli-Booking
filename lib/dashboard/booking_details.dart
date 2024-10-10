import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetails extends StatelessWidget {
  final String travelerName;
  final String travelerId;
  final String currentLocation;
  final String destination;
  final String phoneNumber;
  final String luggage; // Parameter for luggage
  final String bookingId;
  final String initialStatus; // Parameter for initial booking status
  final Timestamp createdAt; // Store Timestamp directly
  late final String createdAtString; // Formatted date string

  BookingDetails({
    super.key,
    required this.travelerName,
    required this.travelerId,
    required this.currentLocation,
    required this.destination,
    required this.phoneNumber,
    required this.luggage, // Initialize luggage
    required this.createdAt, // Store the Timestamp directly
    required this.bookingId,
    required this.initialStatus, // Initialize the status
  }) {
    // Format createdAt to string
    createdAtString = "${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year} ${createdAt.toDate().hour}:${createdAt.toDate().minute}";
  }

  // Logic to confirm the booking
  Future<void> _confirmBooking(BuildContext context) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Update booking status to confirmed
      await firestore.collection('bookings').doc(bookingId).update({
        'status': 'confirmed',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Confirmed')),
      );
    } catch (e) {
      print('Error confirming booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error confirming booking')),
      );
    }
  }

  // Logic to cancel the booking
  Future<void> _cancelBooking(BuildContext context) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Update booking status to canceled
      await firestore.collection('bookings').doc(bookingId).update({
        'status': 'canceled',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Canceled')),
      );
    } catch (e) {
      print('Error canceling booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error canceling booking')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the color based on the booking status
    Color statusColor;
    String statusText;

    if (initialStatus == 'confirmed') {
      statusColor = Colors.green; // Color for confirmed bookings
      statusText = 'Confirmed';
    } else if (initialStatus == 'canceled') {
      statusColor = Colors.red; // Color for canceled bookings
      statusText = 'Canceled';
    } else {
      statusColor = Colors.grey; // Default color for unknown status
      statusText = 'Pending'; // Default text
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: Container(
        color: const Color.fromARGB(255, 249, 112, 112), // Background color
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.person, 'Traveler Name: $travelerName'),
                    _buildDetailRow(Icons.badge, 'Traveler ID: $travelerId'),
                    _buildDetailRow(Icons.location_on, 'Current Location: $currentLocation'),
                    _buildDetailRow(Icons.arrow_forward, 'Destination: $destination'),
                    _buildDetailRow(Icons.phone, 'Phone Number: $phoneNumber'),
                    _buildDetailRow(Icons.luggage, 'Luggage: $luggage'), // Display luggage
                    _buildDetailRow(Icons.calendar_today, 'Booked At: $createdAtString'), // Display formatted date
                    const SizedBox(height: 20),
                    Text(
                      'Status: $statusText',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _confirmBooking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Confirm'),
                ),
                ElevatedButton(
                  onPressed: () => _cancelBooking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a detail row with an icon
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
