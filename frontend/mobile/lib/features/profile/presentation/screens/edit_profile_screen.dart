import 'package:flutter/material.dart';
import '../../../../core/widgets/zb_button.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 32),
            ZbButton(label: 'Save Changes', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
