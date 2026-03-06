import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'employee_time_log_page.dart';
import 'inventory_page.dart';
import 'navigator_helper.dart';
import 'styled_app_bar.dart';

class EmployeeDashPage extends StatefulWidget {
  const EmployeeDashPage({super.key});

  @override
  State<EmployeeDashPage> createState() => _EmployeeDashPageState();
}

class _EmployeeDashPageState extends State<EmployeeDashPage> {
  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {
        'name': 'Employee',
        'companyName': 'No Company',
        'weeklyHours': 0.0,
        'weeklyTips': 0.0,
        'weeklyShifts': 0,
      };
    }

    final db = FirebaseFirestore.instance;
    final userDoc = await db.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? <String, dynamic>{};

    final name = (userData['name'] ?? 'Employee').toString();
    final companyId = (userData['companyId'] ?? '').toString();

    if (companyId.isEmpty) {
      return {
        'name': name,
        'companyName': 'Not Connected',
        'weeklyHours': 0.0,
        'weeklyTips': 0.0,
        'weeklyShifts': 0,
      };
    }

    final companyDoc = await db.collection('companies').doc(companyId).get();
    final companyName = (companyDoc.data()?['name'] ?? 'Your Company')
        .toString();

    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    QuerySnapshot<Map<String, dynamic>> worklogsSnap;
    try {
      // Simple query avoids composite-index failures from date-range + uid.
      worklogsSnap = await db
          .collection('companies')
          .doc(companyId)
          .collection('worklogs')
          .where('employeeUid', isEqualTo: user.uid)
          .get();
    } catch (_) {
      return {
        'name': name,
        'companyName': companyName,
        'weeklyHours': 0.0,
        'weeklyTips': 0.0,
        'weeklyShifts': 0,
      };
    }

    double weeklyHours = 0;
    double weeklyTips = 0;
    int weeklyShifts = 0;

    for (final doc in worklogsSnap.docs) {
      final data = doc.data();
      final workDateTs = data['workDate'] as Timestamp?;
      final workDate = workDateTs?.toDate();
      if (workDate == null) {
        continue;
      }
      if (workDate.isBefore(weekStart) || !workDate.isBefore(weekEnd)) {
        continue;
      }

      final hours = data['hours'];
      final tips = data['tips'];

      weeklyHours += hours is num ? hours.toDouble() : 0;
      weeklyTips += tips is num ? tips.toDouble() : 0;
      weeklyShifts += 1;
    }

    return {
      'name': name,
      'companyName': companyName,
      'weeklyHours': weeklyHours,
      'weeklyTips': weeklyTips,
      'weeklyShifts': weeklyShifts,
    };
  }

  Widget _quickActionCard({
    required Color iconBg,
    required Color accent,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                width: 170,
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
    );
  }

  Widget _metricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade100),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: iconBg,
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDashboardData(),
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final name = (snapshot.data?['name'] ?? 'Employee').toString();
        final companyName = (snapshot.data?['companyName'] ?? 'No Company')
            .toString();
        final weeklyHours = ((snapshot.data?['weeklyHours'] ?? 0.0) as num)
            .toDouble();
        final weeklyTips = ((snapshot.data?['weeklyTips'] ?? 0.0) as num)
            .toDouble();
        final weeklyShifts = ((snapshot.data?['weeklyShifts'] ?? 0) as num)
            .toInt();

        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: buildPrimaryAppBar(context, title: 'Employee Dashboard'),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Expanded(
                flex: 14,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                          radius: 30,
                          backgroundColor: Color(0xFFC8E6C9),
                          child: Icon(
                            Icons.person,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            'Welcome back,',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          Text(
                            loading ? 'Loading...' : name,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      if (snapshot.hasError)
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Icon(Icons.warning_amber, color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Expanded(
                flex: 10,
                child: _sectionCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.business,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Company',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              companyName,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Expanded(
                flex: 16,
                child: _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          children: [
                            _metricTile(
                              title: 'Hours',
                              value: weeklyHours.toStringAsFixed(2),
                              icon: Icons.schedule,
                              iconColor: Colors.green,
                              iconBg: const Color(0xFFE8F5E9),
                            ),
                            const SizedBox(width: 8),
                            _metricTile(
                              title: 'Tips',
                              value: '\$${weeklyTips.toStringAsFixed(2)}',
                              icon: Icons.payments,
                              iconColor: Colors.orange,
                              iconBg: const Color(0xFFFFF3E0),
                            ),
                            const SizedBox(width: 8),
                            _metricTile(
                              title: 'Shifts',
                              value: '$weeklyShifts',
                              icon: Icons.event_note,
                              iconColor: Colors.blue,
                              iconBg: const Color(0xFFE3F2FD),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
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
              const SizedBox(height: 8),
              Expanded(
                flex: 60,
                child: Column(
                  children: [
                    Expanded(
                      child: _quickActionCard(
                        iconBg: const Color(0xFFC8E6C9),
                        accent: Colors.green,
                        icon: Icons.shelves,
                        title: 'Check Inventory',
                        subtitle: 'View and manage all products in stock.',
                        onPressed: () =>
                            goToPage(context, const InventoryPage()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _quickActionCard(
                        iconBg: const Color(0xFFFFF3E0),
                        accent: Colors.orange,
                        icon: Icons.punch_clock,
                        title: 'Log Hours & Tips',
                        subtitle: 'Record your work hours and tip amounts.',
                        onPressed: () =>
                            goToPage(context, const EmployeeTimeLogPage()),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
