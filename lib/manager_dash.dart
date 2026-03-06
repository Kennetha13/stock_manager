import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'inventory_page.dart';
import 'manager_reports_page.dart';
import 'navigator_helper.dart';

class ManagerDashPage extends StatefulWidget {
  const ManagerDashPage({super.key});

  @override
  State<ManagerDashPage> createState() => _ManagerDashPageState();
}

class _ManagerDashPageState extends State<ManagerDashPage> {
  // ✅ One fetch for everything needed on this page (name + company + access code)
  Future<Map<String, String>> _fetchDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not logged in");

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final userData = userDoc.data();
    if (userData == null) throw Exception("User profile not found");

    final name = (userData["name"] ?? "Manager").toString();
    final companyId = (userData["companyId"] ?? "").toString();
    if (companyId.isEmpty) throw Exception("No company assigned");

    final companyDoc = await FirebaseFirestore.instance
        .collection("companies")
        .doc(companyId)
        .get();

    final companyData = companyDoc.data();
    if (companyData == null) throw Exception("Company not found");

    final companyName = (companyData["name"] ?? "").toString();
    final accessCode = (companyData["accessCode"] ?? "").toString();

    return {"name": name, "companyName": companyName, "accessCode": accessCode};
  }

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Access code copied")));
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
      flex: 22,
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
    return FutureBuilder<Map<String, String>>(
      future: _fetchDashboardData(),
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;

        // Default/fallback values so UI still renders nicely
        final name = snapshot.data?["name"] ?? "Manager";
        final companyName = snapshot.data?["companyName"] ?? "Your Company";
        final accessCode = snapshot.data?["accessCode"] ?? "";

        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: const Text(
              'Manager Dashboard',
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
              // Welcome card (now shows real name)
              Expanded(
                flex: 15,
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
                          const SizedBox(height: 15),
                          const Text(
                            'Welcome back,',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          Text(
                            loading ? "Loading..." : name,
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

              // Access Code card
              Expanded(
                flex: 15,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // const CircleAvatar(
                        //   radius: 32,
                        //   backgroundColor: Color(0xFFC8E6C9),
                        //   child: Icon(Icons.lock_outline, color: Colors.green, size: 34),
                        // ),
                        //const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loading ? "Loading..." : companyName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 1),
                              const Text(
                                "Employee Access Code",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  loading ? "----" : accessCode,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 6,
                                  ),
                                ),
                              ),
                              if (snapshot.hasError)
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    "Couldn’t load dashboard data.",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white),
                            onPressed: (loading || accessCode.isEmpty)
                                ? null
                                : () => _copyCode(context, accessCode),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Quick Actions',
                  textAlign: TextAlign.right,
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
                title: "Check Inventory",
                subtitle: "View and manage all products in stock.",
                onPressed: () {
                  goToPage(context, const InventoryPage());
                },
              ),

              _quickActionCard(
                iconBg: const Color(0xFFFFF3E0),
                accent: Colors.orange,
                icon: Icons.edit_document,
                title: "Generate Reports",
                subtitle: "View employee hours, tips, and performance.",
                onPressed: () {
                  goToPage(context, const ManagerReportsPage());
                },
              ),

              Expanded(
                flex: 15,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.blue[100],
                          child: const Icon(
                            Icons.people_rounded,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Employee Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: Text(
                              'View and edit company employees.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.blue,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: navigate to employee status page
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
