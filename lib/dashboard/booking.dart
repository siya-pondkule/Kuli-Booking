import 'package:flutter/material.dart';

class KuliBookings extends StatelessWidget {
  final String kuliId;
  final String userId;

  const KuliBookings({super.key, required this.kuliId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Bookings for Kuli ID: $kuliId\nUser ID: $userId'),
    );
  }
}
