import 'package:flutter/material.dart'; 


class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
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
      child: Text('Wallet Content Here'), 
    );
  }
}
