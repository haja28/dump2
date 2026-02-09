import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;
  
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Center(
        child: Text('Order $orderId Details - To be implemented'),
      ),
    );
  }
}
