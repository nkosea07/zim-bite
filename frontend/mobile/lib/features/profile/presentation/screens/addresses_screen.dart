import 'package:flutter/material.dart';
import '../../../../core/widgets/zb_empty_state.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: const ZbEmptyState(
        icon: Icons.location_on_outlined,
        title: 'No addresses saved',
        subtitle: 'Add a delivery address to get started',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // TODO: add address dialog
        child: const Icon(Icons.add),
      ),
    );
  }
}
