import 'package:flutter/material.dart';

class MenuItemDetailScreen extends StatelessWidget {
  final int itemId;
  
  const MenuItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Item Details'),
      ),
      body: Center(
        child: Text('Menu Item $itemId Details - To be implemented'),
      ),
    );
  }
}
