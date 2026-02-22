import'package:flutter/material.dart';

class EmployeeDashPage extends StatefulWidget {
  const EmployeeDashPage({super.key});

  @override
  State<EmployeeDashPage> createState() => _EmployeeDashPageState();
}

class _EmployeeDashPageState extends State<EmployeeDashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(
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
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFC8E6C9),
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
                          Text(
                              'Welcome back,',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey
                              )
                          ),
                          Text(
                            'Employee',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              ),
            ),

            Padding(
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

            Expanded(
              flex: 40,
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // left
                  crossAxisAlignment: CrossAxisAlignment.center, // top
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFC8E6C9),
                        child: Icon(
                          Icons.shelves,
                          color: Colors.green,
                          size: 50,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check Inventory',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: 160, // adjust as needed
                          child: Text(
                            'View and manage all products in stock.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 35),

                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 40,
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // left
                  crossAxisAlignment: CrossAxisAlignment.center, // top
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFFFF3E0),
                        child: Icon(
                          Icons.punch_clock,
                          color: Colors.orange,
                          size: 50,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Log Hours & Tips',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: 160, // adjust as needed
                          child: Text(
                            'Record your work hours and tip amounts.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 35),

                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.orange,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        )
    );
  }
}
