import 'package:flutter/material.dart';
import 'package:stock_mananger_1/employee_signup_page.dart';
import 'manager_signup_page.dart';
import 'navigator_helper.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Back button + title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // balance the back button
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Join Stock Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Choose how you'd like to get started",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 32),

                // Manager Card
                Expanded(
                  flex:30,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Color(0xFFC8E6C9),
                              child: Icon(
                                Icons.business_center,
                                color: Colors.green,
                                size: 40,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Manager',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text('Set up your company workspace',
                                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 70),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        '• ',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30
                                      ),
                                    ),
                                    Text('Create your company profile'),
                                  ]
                                ),
                                Row(
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30
                                        ),
                                      ),
                                      Text('Invite employees with join codes'),
                                    ]
                                ),
                                Row(
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30
                                        ),
                                      ),
                                      Text('Full inventory & team control'),
                                    ]
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => goToPage(context, ManagerSignUpPage()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF388E3C),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Sign Up as Manager',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),




                // Employee Card


                Expanded(
                  flex:30,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Color(0xFFC8E6C9),
                              child: Icon(
                                Icons.person,
                                color: Colors.green,
                                size: 40,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Employee',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text("Join your company's workspace",
                                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 70),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            child: Column(
                              children: [
                                Row(
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30
                                        ),
                                      ),
                                      Text('Enter your company join code'),
                                    ]
                                ),
                                Row(
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30
                                        ),
                                      ),
                                      Text('Access your team\'s inventory'),
                                    ]
                                ),
                                Row(
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30
                                        ),
                                      ),
                                      Text("Log your hour's and tips"),
                                    ]
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => goToPage(context, EmployeeSignUpPage()),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF43A047), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Sign Up as Employee',
                              style: TextStyle(
                                  color: Color(0xFF43A047), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

