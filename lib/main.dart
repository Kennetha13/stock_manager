import 'package:flutter/material.dart';
import 'package:stock_mananger_1/inventory_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

  void goToInventory(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const InventoryPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.green,
        body: Center(
          child: Container(
            width: 350,
            height: 500,
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
                    Icons.shelves,
                    color: Colors.green,
                    size: 100.0,
                  ),
                ),
                Text(
                  'Stock Manager',
                      style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                        color: Colors.green,
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
                        color: Colors.green
                    )
                ),

                Container(
                  margin: EdgeInsets.only(top: 30),
                  width: 125,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green
                      ),
                      onPressed: goToInventory,
                      child: Text('Login',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white
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
