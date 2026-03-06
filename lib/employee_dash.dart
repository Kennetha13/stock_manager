import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'employee_time_log_page.dart';
import 'inventory_page.dart';
import 'navigator_helper.dart';

class EmployeeDashPage extends StatefulWidget {
  const EmployeeDashPage({super.key});

  @override
  State<EmployeeDashPage> createState() => _EmployeeDashPageState();
}

class _EmployeeDashPageState extends State<EmployeeDashPage> {
  Future<String> _fetchEmployeeName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Employee';
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data();
    return (data?['name'] ?? 'Employee').toString();
  }

  Widget _quickActionCard({
    required Color iconBg,
    required Color accent,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      flex: 35,
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: iconBg,
                child: Icon(icon, color: accent, size: 50),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: Text(
                    subtitle,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: accent,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: onPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchEmployeeName(),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'Employee';

        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: const Text(
              'Employee Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 20,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFFC8E6C9),
                          child: Icon(
                            Icons.person,
                            color: Colors.green,
                            size: 60,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          const Text(
                            'Welcome back,',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          Text(
                            snapshot.connectionState == ConnectionState.waiting
                                ? 'Loading...'
                                : name,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              _quickActionCard(
                iconBg: const Color(0xFFC8E6C9),
                accent: Colors.green,
                icon: Icons.shelves,
                title: 'Check Inventory',
                subtitle: 'View and manage all products in stock.',
                onPressed: () => goToPage(context, const InventoryPage()),
              ),
              _quickActionCard(
                iconBg: const Color(0xFFFFF3E0),
                accent: Colors.orange,
                icon: Icons.punch_clock,
                title: 'Log Hours & Tips',
                subtitle: 'Record your work hours and tip amounts.',
                onPressed: () => goToPage(context, const EmployeeTimeLogPage()),
              ),
            ],
          ),
        );
      },
    );
  }
}
