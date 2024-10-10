import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'profile.dart';
import 'wallet.dart';
import 'feedback.dart';
import 'booking_details.dart';

class KuliDashboard extends StatefulWidget {
  const KuliDashboard({Key? key}) : super(key: key);

  @override
  State<KuliDashboard> createState() => _KuliDashboardState();
}

class _KuliDashboardState extends State<KuliDashboard> {
  int _currentIndex = 0;
  String? kuliId;
  String? userId;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeUserDetails();
  }

  Future<void> createUserDocument(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      try {
        await userDoc.set({
          'kuliId': user.uid,
        });
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to create user document: $e';
          isLoading = false; // Stop loading
        });
      }
    }
  }

  Future<void> _initializeUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid; // Set userId from FirebaseAuth
        });

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userSnapshot.exists) {
          setState(() {
            kuliId = userSnapshot['kuliId'] ?? ''; // Fetch 'kuliId' from Firestore
            isLoading = false; // Set loading to false once IDs are retrieved
          });
        } else {
          await createUserDocument(user);
          setState(() {
            isLoading = false;
            errorMessage = null; // Reset error message
          });
          userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          setState(() {
            kuliId = userSnapshot['kuliId'] ?? ''; // Fetch kuliId again after creating the document
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'User not logged in.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error initializing user details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
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
                  icon: Icon(Icons.book, color: Colors.red),
                  label: "Bookings",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet, color: Colors.red),
                  label: "Wallet",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.feedback, color: Colors.red),
                  label: "Feedback",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, color: Colors.red),
                  label: "Profile",
                ),
              ],
            ),
            body: _getBodyWidget(),
          );
  }

  Widget _getBodyWidget() {
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (kuliId == null || userId == null || kuliId!.isEmpty) {
      return const Center(child: Text('Error: Kuli or User ID not found'));
    }

    switch (_currentIndex) {
      case 0:
        return KuliBookings(kuliId: kuliId!, userId: userId!);
      case 1:
        return const Wallet();
      case 2:
        return const FeedbackPage();
      case 3:
        return const KuliProfile();
      default:
        return Container();
    }
  }
}

class KuliBookings extends StatefulWidget {
  final String kuliId;
  final String userId;

  const KuliBookings({Key? key, required this.kuliId, required this.userId}) : super(key: key);

  @override
  _KuliBookingsState createState() => _KuliBookingsState();
}

class _KuliBookingsState extends State<KuliBookings> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchKuliBookings();
  }

  Future<void> _fetchKuliBookings() async {
    try {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('kuli.kuliId', isEqualTo: widget.kuliId)
          .get();

      if (bookingsSnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'No bookings found for this Kuli.';
        });
      } else {
        bookings = bookingsSnapshot.docs.map((booking) {
          var bookingData = booking.data() as Map<String, dynamic>;
          return {
            ...bookingData,
            'id': booking.id, // Add booking ID here
          };
        }).toList();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching bookings: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : bookings.isEmpty
                ? const Center(child: Text('No bookings available.'))
                : ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final traveler = booking['traveler'];
                      final kuli = booking['kuli'];

                      final travelerName = traveler?['name'] ?? 'No traveler name available';
                      final travelerId = traveler?['travelerId'] ?? 'N/A';
                      final currentLocation = traveler?['current_location'] ?? 'N/A';
                      final destination = traveler?['destination'] ?? 'N/A';
                      final phoneNumber = traveler?['phone_number'] ?? 'N/A';
                      final luggage = booking['luggage'] ?? 'N/A'; // Get the luggage information
                      final bookingId = booking['id']; // Get the booking ID from the updated booking map
                      final bookingStatus = booking['status'] ?? 'pending'; // Get the booking status

                      // Ensure createdAt is a Timestamp
                      final createdAtTimestamp = booking['createdAt'] as Timestamp?;
                      final createdAt = createdAtTimestamp != null
                          ? DateFormat('yyyy-MM-dd – kk:mm').format(createdAtTimestamp.toDate())
                          : 'N/A';

                      return BookingCard(
                        travelerName: travelerName,
                        travelerId: travelerId,
                        currentLocation: currentLocation,
                        destination: destination,
                        phoneNumber: phoneNumber,
                        luggage: luggage, // Pass the luggage information
                        createdAt: createdAt,
                        bookingId: bookingId, // Pass the booking ID
                        initialStatus: bookingStatus, // Pass the booking status
                        onBookingDetailsTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetails(
                                bookingId: bookingId,
                                travelerId: travelerId,
                                travelerName: travelerName,
                                currentLocation: currentLocation,
                                destination: destination,
                                phoneNumber: phoneNumber,
                                luggage: luggage, // Pass the luggage information to BookingDetails
                                createdAt: createdAtTimestamp ?? Timestamp.now(), // Pass a default Timestamp if null
                                initialStatus: bookingStatus, // Pass the booking status to BookingDetails
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
  }
}

class BookingCard extends StatelessWidget {
  final String travelerName;
  final String travelerId;
  final String currentLocation;
  final String destination;
  final String phoneNumber;
  final String luggage; // New luggage field
  final String createdAt;
  final String bookingId;
  final String initialStatus;
  final VoidCallback onBookingDetailsTap;

  const BookingCard({
    Key? key,
    required this.travelerName,
    required this.travelerId,
    required this.currentLocation,
    required this.destination,
    required this.phoneNumber,
    required this.luggage, // Add luggage field here
    required this.createdAt,
    required this.bookingId,
    required this.initialStatus,
    required this.onBookingDetailsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: ListTile(
        title: Text(travelerName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Traveler ID: $travelerId'),
            Text('From: $currentLocation'),
            Text('To: $destination'),
            Text('Phone: $phoneNumber'),
            Text('Luggage: $luggage'), // Display luggage information
            Text('Date: $createdAt'),
            Text('Status: $initialStatus'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: onBookingDetailsTap,
        ),
      ),
    );
  }
}
