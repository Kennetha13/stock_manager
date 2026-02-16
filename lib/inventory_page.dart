import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {

  final productRef = FirebaseFirestore.instance.collection('Product');

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
            child: const Text(
                'Add Product',
                style: TextStyle(
                    color: Colors.green
                )
            )
        ),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'Product Name',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'Quantity',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 60),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final qtyText = quantityController.text.trim();
                final qty = int.tryParse(qtyText);

                // Basic validation
                if (name.isEmpty || qty == null) return;

                try {
                  await productRef.add({
                    "name": name,
                    "quantity": qty,
                  });

                  if (context.mounted) Navigator.pop(context); //screen is still showing
                } catch (e) {
                  // Optional: show an error to the user
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to add product: $e")),
                  );
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
        title: Text(
          'Inventory',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
          children: [
            Container(
                margin: EdgeInsets.all(20),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0)
                    ),
                    labelText: 'Search Products..',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),


          ]
        ),






      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product',style: TextStyle(color: Colors.white)),
      ),

    );
  }
}
