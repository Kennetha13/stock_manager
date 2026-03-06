import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployeeTimeLogPage extends StatefulWidget {
  const EmployeeTimeLogPage({super.key});

  @override
  State<EmployeeTimeLogPage> createState() => _EmployeeTimeLogPageState();
}

class _EmployeeTimeLogPageState extends State<EmployeeTimeLogPage> {
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _tipsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  bool _loadingProfile = true;
  bool _saving = false;
  String? _errorMessage;

  String _companyId = '';
  String _employeeName = 'Employee';
  String _employeeEmail = '';
  String _employeeUid = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loadingProfile = false;
        _errorMessage = 'You must be logged in to log hours.';
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = userDoc.data();

      setState(() {
        _employeeUid = user.uid;
        _companyId = (data?['companyId'] ?? '').toString();
        _employeeName = (data?['name'] ?? 'Employee').toString();
        _employeeEmail = (data?['email'] ?? user.email ?? '').toString();
      });

      if (_companyId.isEmpty) {
        setState(() {
          _errorMessage = 'You must join a company before logging hours.';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _loadingProfile = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _saveWorkLog() async {
    if (_companyId.isEmpty || _employeeUid.isEmpty) {
      setState(() {
        _errorMessage = 'Unable to find your company or account details.';
      });
      return;
    }

    final hours = double.tryParse(_hoursController.text.trim());
    final tipsText = _tipsController.text.trim();
    final tips = tipsText.isEmpty ? 0 : double.tryParse(tipsText);

    if (hours == null || hours <= 0) {
      setState(() {
        _errorMessage = 'Enter a valid hour amount greater than 0.';
      });
      return;
    }

    if (tips == null || tips < 0) {
      setState(() {
        _errorMessage = 'Enter a valid tip amount (0 or more).';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final workDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      await FirebaseFirestore.instance
          .collection('companies')
          .doc(_companyId)
          .collection('worklogs')
          .add({
            'companyId': _companyId,
            'employeeUid': _employeeUid,
            'employeeName': _employeeName,
            'employeeEmail': _employeeEmail,
            'workDate': Timestamp.fromDate(workDate),
            'hours': hours,
            'tips': tips,
            'createdAt': FieldValue.serverTimestamp(),
          });

      _hoursController.clear();
      _tipsController.clear();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hours and tips logged successfully.')),
      );
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _showEditLogDialog({
    required String docId,
    required DateTime currentDate,
    required double currentHours,
    required double currentTips,
  }) async {
    final hoursController = TextEditingController(
      text: currentHours.toStringAsFixed(2),
    );
    final tipsController = TextEditingController(
      text: currentTips.toStringAsFixed(2),
    );
    DateTime selectedDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? dialogError;
        bool updating = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickEditDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setDialogState(() {
                  selectedDate = picked;
                });
              }
            }

            Future<void> updateShift() async {
              final newHours = double.tryParse(hoursController.text.trim());
              final newTips = double.tryParse(tipsController.text.trim());

              if (newHours == null || newHours <= 0) {
                setDialogState(() {
                  dialogError = 'Enter valid hours greater than 0.';
                });
                return;
              }

              if (newTips == null || newTips < 0) {
                setDialogState(() {
                  dialogError = 'Enter valid tips (0 or more).';
                });
                return;
              }

              setDialogState(() {
                updating = true;
                dialogError = null;
              });

              try {
                await FirebaseFirestore.instance
                    .collection('companies')
                    .doc(_companyId)
                    .collection('worklogs')
                    .doc(docId)
                    .update({
                      'workDate': Timestamp.fromDate(
                        DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                        ),
                      ),
                      'hours': newHours,
                      'tips': newTips,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

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
                  updating = false;
                });
              }
            }

            Future<void> deleteShift() async {
              setDialogState(() {
                updating = true;
                dialogError = null;
              });

              try {
                await FirebaseFirestore.instance
                    .collection('companies')
                    .doc(_companyId)
                    .collection('worklogs')
                    .doc(docId)
                    .delete();
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
                  updating = false;
                });
              }
            }

            return AlertDialog(
              title: const Text(
                'Edit Shift Entry',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: updating ? null : pickEditDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text('Date: ${_dateLabel(selectedDate)}'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hoursController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Hours',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tipsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Tips',
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
                  onPressed: updating
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: updating ? null : deleteShift,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: updating ? null : updateShift,
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

  Widget _buildRecentLogs() {
    if (_companyId.isEmpty || _employeeUid.isEmpty) {
      return const Center(child: Text('No logs to show yet.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc(_companyId)
          .collection('worklogs')
          .where('employeeUid', isEqualTo: _employeeUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading your logs'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aTs = a.data()['workDate'] as Timestamp?;
            final bTs = b.data()['workDate'] as Timestamp?;
            final aDate =
                aTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate =
                bTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

        if (docs.isEmpty) {
          return const Center(child: Text('No logged shifts yet.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final docId = docs[index].id;
            final ts = data['workDate'] as Timestamp?;
            final date = ts?.toDate() ?? DateTime.now();

            final hours = data['hours'] is num
                ? (data['hours'] as num).toDouble()
                : double.tryParse((data['hours'] ?? '').toString()) ?? 0;
            final tips = data['tips'] is num
                ? (data['tips'] as num).toDouble()
                : double.tryParse((data['tips'] ?? '').toString()) ?? 0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFFF3E0),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(
                        color: Colors.orange,
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
                          _dateLabel(date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Hours: ${hours.toStringAsFixed(2)}'),
                        Text('Tips: \$${tips.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showEditLogDialog(
                        docId: docId,
                        currentDate: date,
                        currentHours: hours,
                        currentTips: tips,
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.green),
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
      appBar: AppBar(
        title: const Text(
          'Log Hours & Tips',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _employeeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_employeeEmail.isNotEmpty)
                        Text(
                          _employeeEmail,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text('Work Date: ${_dateLabel(_selectedDate)}'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _hoursController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Hours Worked',
                          hintText: '8.0',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _tipsController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Tip Amount',
                          hintText: '0.00',
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: _saving ? null : _saveWorkLog,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Save Entry',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Entries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildRecentLogs()),
              ],
            ),
    );
  }
}
