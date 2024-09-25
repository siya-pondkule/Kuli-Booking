import 'package:flutter/material.dart';
import 'booking.dart';
import 'profile.dart';
import 'wallet.dart';
import 'feedback.dart';

class KuliDashboard extends StatefulWidget {
  const KuliDashboard({super.key});

  @override
  State<KuliDashboard> createState() => _KuliDashboardState();
}

class _KuliDashboardState extends State<KuliDashboard> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Mr. COOLIE'),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Wallets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      body: getBodyWidget(),
    );
  }

  Widget getBodyWidget() {
    switch (_currentIndex) {
      case 0:
        return const Booking();
      case 1:
        return const Wallet();
      case 2:
        return const FeedbackPage();
      case 3:
        return const Profile(); 
      default:
        return Container();
    }
  }
}
