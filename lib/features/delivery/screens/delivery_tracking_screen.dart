import 'package:flutter/material.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  final int orderId;
  
  const DeliveryTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Delivery'),
      ),
      body: Center(
        child: Text('Delivery Tracking for Order $orderId - To be implemented'),
      ),
    );
  }
}
