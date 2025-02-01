import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBagPopup extends StatelessWidget {
  final TextEditingController bagNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController currentEmailController = TextEditingController();

  AddBagPopup({super.key});

  Future<void> saveBagToFirebase(
      String bagName, String ownerName, String userId, String userEmail) async {
    await FirebaseFirestore.instance.collection('bags').add({
      'name': bagName,
      'owner': ownerName,
      'userId': userId, // Store the User ID
      'userEmail': userEmail, // Store the User Email
      'timestamp': FieldValue.serverTimestamp(), // Store when the bag was added
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Add New Bag',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: bagNameController,
            decoration: const InputDecoration(
              labelText: 'Name of the Bag',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: ownerNameController,
            decoration: const InputDecoration(
              labelText: "Owner's Name",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (context.mounted) Navigator.pop(context); // Close the popup
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            String bagName = bagNameController.text.trim();
            String ownerName = ownerNameController.text.trim();

            // Get current logged-in user
            User? user = FirebaseAuth.instance.currentUser;

            if (user != null && bagName.isNotEmpty && ownerName.isNotEmpty) {
              String userId = user.uid; // Get User ID
              String userEmail =
                  user.email ?? "Unknown"; // Get User Email (Optional)

              await saveBagToFirebase(
                  bagName, ownerName, userId, userEmail); // Pass user details
              Navigator.pop(context); // Close the popup
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all fields or log in first'),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
