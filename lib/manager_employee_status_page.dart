import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'styled_app_bar.dart';

class ManagerEmployeeStatusPage extends StatefulWidget {
  const ManagerEmployeeStatusPage({super.key});

  @override
  State<ManagerEmployeeStatusPage> createState() =>
      _ManagerEmployeeStatusPageState();
}

class _ManagerEmployeeStatusPageState extends State<ManagerEmployeeStatusPage> {
  String _companyId = '';
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  Future<void> _loadCompanyId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'You must be logged in.';
        _loading = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final companyId = (userDoc.data()?['companyId'] ?? '').toString();
      if (companyId.isEmpty) {
        setState(() {
          _errorMessage = 'No company found for this manager account.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _companyId = companyId;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showEditEmployeeDialog({
    required String employeeUid,
    required String currentName,
    required String currentEmail,
  }) async {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? dialogError;
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveEmployee() async {
              final newName = nameController.text.trim();
              final newEmail = emailController.text.trim();

              if (newName.isEmpty || newEmail.isEmpty) {
                setDialogState(() {
                  dialogError = 'Name and email are required.';
                });
                return;
              }

              setDialogState(() {
                saving = true;
                dialogError = null;
              });

              try {
                final db = FirebaseFirestore.instance;
                final batch = db.batch();

                batch.update(
                  db
                      .collection('companies')
                      .doc(_companyId)
                      .collection('employees')
                      .doc(employeeUid),
                  {
                    'name': newName,
                    'email': newEmail,
                    'updatedAt': FieldValue.serverTimestamp(),
                  },
                );

                batch.update(db.collection('users').doc(employeeUid), {
                  'name': newName,
                  'email': newEmail,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                await batch.commit();

                if (!dialogContext.mounted) {
                  return;
                }
                Navigator.pop(dialogContext);
              } catch (error) {
                setDialogState(() {
                  dialogError = error.toString();
                });
              } finally {
                setDialogState(() {
                  saving = false;
                });
              }
            }

            Future<void> removeEmployee() async {
              final confirm = await showDialog<bool>(
                context: dialogContext,
                builder: (confirmContext) => AlertDialog(
                  title: const Text(
                    'Remove Employee?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  content: Text(
                    'This will remove $currentName from your company roster.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(confirmContext, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(confirmContext, true),
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm != true) {
                return;
              }

              setDialogState(() {
                saving = true;
                dialogError = null;
              });

              try {
                final db = FirebaseFirestore.instance;
                final batch = db.batch();

                batch.delete(
                  db
                      .collection('companies')
                      .doc(_companyId)
                      .collection('employees')
                      .doc(employeeUid),
                );

                batch.set(db.collection('users').doc(employeeUid), {
                  'companyId': '',
                  'removedFromCompanyAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                await batch.commit();

                if (!dialogContext.mounted) {
                  return;
                }
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$currentName removed from company.')),
                );
              } catch (error) {
                setDialogState(() {
                  dialogError = error.toString();
                });
              } finally {
                setDialogState(() {
                  saving = false;
                });
              }
            }

            return AlertDialog(
              title: const Text(
                'Edit Employee',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: Color(0xFF388E3C),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: Color(0xFF388E3C),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (dialogError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          dialogError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: saving ? null : removeEmployee,
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: saving ? null : saveEmployee,
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeesList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_companyId.isEmpty) {
      return const Center(child: Text('No company employees found.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc(_companyId)
          .collection('employees')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading employees'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aName = (a.data()['name'] ?? '').toString().toLowerCase();
            final bName = (b.data()['name'] ?? '').toString().toLowerCase();
            return aName.compareTo(bName);
          });

        if (docs.isEmpty) {
          return const Center(child: Text('No employees in this company yet.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final name = (data['name'] ?? 'Employee').toString();
            final email = (data['email'] ?? '').toString();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFC8E6C9),
                    child: Text(
                      name.isEmpty ? '?' : name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.green,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () {
                      _showEditEmployeeDialog(
                        employeeUid: doc.id,
                        currentName: name,
                        currentEmail: email,
                      );
                    },
                  ),
                ],
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
      appBar: buildPrimaryAppBar(context, title: 'Employee Status'),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Row(
              children: [
                Icon(Icons.people_rounded, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'View and edit employee names and emails for your company.',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildEmployeesList()),
        ],
      ),
    );
  }
}
