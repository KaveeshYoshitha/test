import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bag_details_page.dart';
import 'add_bag_popup.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC1E4E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC1E4E9),
        elevation: 0,
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile_image.png'),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
            color: Colors.black,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, User1',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bags')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No bags added yet.',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final bags = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: bags.length,
                    itemBuilder: (context, index) {
                      final bag = bags[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        color: const Color(0xFFFFF9E6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text('Bag: ${bag['name']}'),
                          subtitle: Text("Owner: ${bag['owner']}"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BagDetailsPage(
                                  bagName: bag['name'],
                                  ownerName: bag['owner'],
                                  onRemoveBag: () async {
                                    await FirebaseFirestore.instance
                                        .runTransaction((transaction) async {
                                      transaction.delete(bag.reference);
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AddBagPopup(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF9E6),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: const Text(
                'Add Bag',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
