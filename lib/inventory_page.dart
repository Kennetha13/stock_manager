import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'styled_app_bar.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  bool _loadingCompany = true;
  String? _companyError;
  String _companyId = '';

  @override
  void initState() {
    super.initState();
    _loadCompanyContext();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyContext() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _companyError = 'You must be logged in to view inventory.';
        _loadingCompany = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      final companyId = (userData?['companyId'] ?? '').toString();

      if (companyId.isEmpty) {
        setState(() {
          _companyError = 'You are not connected to a company yet.';
        });
      } else {
        setState(() {
          _companyId = companyId;
        });
      }
    } catch (error) {
      setState(() {
        _companyError = error.toString();
      });
    } finally {
      setState(() {
        _loadingCompany = false;
      });
    }
  }

  CollectionReference<Map<String, dynamic>> _inventoryRef() {
    return FirebaseFirestore.instance
        .collection('companies')
        .doc(_companyId)
        .collection('inventory');
  }

  void _showAddProductDialog() {
    if (_companyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No company inventory found for your account.'),
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text('Add Product', style: TextStyle(color: Colors.green)),
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
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF388E3C), width: 2),
                ),
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
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF388E3C), width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 60),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final name = nameController.text.trim();
                final qtyText = quantityController.text.trim();
                final qty = int.tryParse(qtyText);

                if (name.isEmpty || qty == null) {
                  return;
                }

                try {
                  await _inventoryRef().add({
                    'name': name,
                    'quantity': qty,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add product: $error')),
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

  void _showEditProductDialog({
    required String docId,
    required String currentName,
    required int currentQuantity,
  }) {
    final nameController = TextEditingController(text: currentName);
    final quantityController = TextEditingController(
      text: currentQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            'Edit Product',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF388E3C), width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF388E3C), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              final confirm = await _confirmDelete(dialogContext);
              if (confirm != true) {
                return;
              }

              try {
                await _inventoryRef().doc(docId).delete();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (error) {
                if (!dialogContext.mounted) {
                  return;
                }
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Failed to delete: $error')),
                );
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final newName = nameController.text.trim();
              final qty = int.tryParse(quantityController.text.trim());

              if (newName.isEmpty || qty == null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a valid name and quantity.'),
                  ),
                );
                return;
              }

              try {
                await _inventoryRef().doc(docId).update({
                  'name': newName,
                  'quantity': qty,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (error) {
                if (!dialogContext.mounted) {
                  return;
                }
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Failed to save: $error')),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete product?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_loadingCompany) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_companyError != null) {
      return Center(child: Text(_companyError!));
    }

    if (_companyId.isEmpty) {
      return const Center(child: Text('No company inventory available.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _inventoryRef().orderBy('quantity').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading products'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        final filtered = docs.where((doc) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().toLowerCase();
          return name.contains(_searchText);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data();

            final docId = doc.id;
            final name = (data['name'] ?? '').toString();
            final quantity = (data['quantity'] ?? 0) is int
                ? data['quantity'] as int
                : int.tryParse(data['quantity'].toString()) ?? 0;

            final lowStock = quantity <= 5;
            final cardColor = lowStock
                ? Colors.red.shade100
                : Colors.green.shade100;
            final statusText = lowStock ? 'Low stock!' : 'In stock';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: lowStock ? Colors.red : Colors.black54,
                              fontWeight: lowStock
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: () {
                        _showEditProductDialog(
                          docId: docId,
                          currentName: name,
                          currentQuantity: quantity,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: buildPrimaryAppBar(context, title: 'Inventory'),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                labelText: 'Search Products..',
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(child: _buildProductsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _companyId.isEmpty ? null : _showAddProductDialog,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
