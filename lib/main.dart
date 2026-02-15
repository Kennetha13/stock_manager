import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'LOGIN'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.lightGreen,
        body: Center(
          child: Container(
            width: 400,
            height: 500, // 👈 fixed height
            margin: EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 30,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: 100.0,
                  ),
                ),
                Text(
                  'Stock Manager',
                      style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                        color: Colors.lightGreen,
                    ),
                ),
                Text(
                  'Manage your inventory with ease',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(25),
                  child: TextField(
                    obscureText: false,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email'),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(left: 25, right: 25, bottom: 5),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password'),
                  ),
                ),

                Text('Forgot Password?',
                    style: TextStyle(
                        color: Colors.lightGreen
                    )
                ),

                Container(
                  margin: EdgeInsets.only(top: 30),
                  width: 125,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen
                      ),
                      onPressed: () {
                      },
                      child: Text('Login',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black
                          )
                      )
                  ),
                ),

              ],
            ),
          ),
        )
    );
  }
}
