import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataSeederUtil {
  static Future<void> showManagerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const _DataManagerDialog(),
    );
  }
}

class _DataManagerDialog extends StatefulWidget {
  const _DataManagerDialog();

  @override
  State<_DataManagerDialog> createState() => _DataManagerDialogState();
}

class _DataManagerDialogState extends State<_DataManagerDialog> {
  bool _isLoading = false;
  String _status = '';

  Future<void> _seedShops() async {
    setState(() {
      _isLoading = true;
      _status = 'Adding dummy shops...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final shops = [
        {'role': 'vendor', 'shopName': 'Spice Garden', 'ownerName': 'Chef Raj', 'description': 'Authentic Indian Biryani & Curries', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
        {'role': 'vendor', 'shopName': 'Dragon Wok', 'ownerName': 'Mei Lin', 'description': 'Delicious Chinese Noodles & Manchurian', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
        {'role': 'vendor', 'shopName': 'Burger Barn', 'ownerName': 'John Doe', 'description': 'American Burgers & Crispy Fries', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
        {'role': 'vendor', 'shopName': 'Chai & Snacks', 'ownerName': 'Amit', 'description': 'Hot Tea, Coffee & Fresh Samosas', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
        {'role': 'vendor', 'shopName': 'Pizza Planet', 'ownerName': 'Mario', 'description': 'Italian Pizzas & Pasta', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
      ];

      for (final shop in shops) {
        final dummyUid = 'mock_${DateTime.now().millisecondsSinceEpoch}_${shop['shopName'].toString().replaceAll(" ", "")}';
        await firestore.collection('users').doc(dummyUid).set(shop);

        await firestore.collection('menu_items').add({
          'vendorId': dummyUid,
          'name': 'Signature ${shop['shopName'].toString().split(' ').last}',
          'description': 'Our famous bestselling item.',
          'price': 150.0,
          'category': 'Specials',
          'imageUrl': '',
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        _status = 'Added 5 dummy shops successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error adding shops: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMockData() async {
    setState(() {
      _isLoading = true;
      _status = 'Deleting dummy shops...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Delete mock users
      final usersQuery = await firestore.collection('users').where('role', isEqualTo: 'vendor').get();
      int deletedUsers = 0;
      for (final doc in usersQuery.docs) {
        if (doc.id.startsWith('mock_')) {
          await doc.reference.delete();
          deletedUsers++;
        }
      }

      // Delete mock items
      final itemsQuery = await firestore.collection('menu_items').get();
      int deletedItems = 0;
      for (final doc in itemsQuery.docs) {
        final vendorId = doc.data()['vendorId'] as String?;
        if (vendorId != null && vendorId.startsWith('mock_')) {
          await doc.reference.delete();
          deletedItems++;
        }
      }

      setState(() {
        _status = 'Deleted $deletedUsers dummy shops and $deletedItems dummy items.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error deleting data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Test Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_isLoading) const CircularProgressIndicator(),
          if (!_isLoading) ...[
            ElevatedButton.icon(
              onPressed: _seedShops,
              icon: const Icon(Icons.add),
              label: const Text('Add 5 Dummy Shops'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _deleteMockData,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete Dummy Data', style: TextStyle(color: Colors.red)),
            ),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
