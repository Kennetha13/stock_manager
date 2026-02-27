import 'package:flutter/material.dart';
import 'navigator_helper.dart';
import 'create_account_page.dart';
import 'manager_dash.dart';
import 'access_code_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  String selectedRole = "employee";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      // Only navigate if login succeeds
      goToPage(context, getDashboardPage());

    } on FirebaseAuthException catch (e) {
      setState(() {
        debugPrint("AUTH ERROR CODE: ${e.code}");
        debugPrint("AUTH ERROR MESSAGE: ${e.message}");
        setState(() => _errorMessage = e.message ?? e.code);

        _errorMessage = 'Wrong Password or Email';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // void goToPage(Widget page) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => page,
  //     ),
  //   );
  // }

  Widget getDashboardPage() {
    return selectedRole == "employee"
        ? const AccessCodePage()
        : const ManagerDashPage();
  }

  Widget _buildRoleButton(String roleValue, String label) {
    const green = Colors.green;

    final bool isSelected = selectedRole == roleValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = roleValue;
        });
      },
      child: Container(
        height: 55,
        width: 146,
        decoration: BoxDecoration(
          color: isSelected ? green : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: green, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              color: isSelected ? Colors.white : green,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : green,
              ),
            ),
          ],
        ),
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
            height: 650,
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

                const SizedBox(height: 10),

                Text(
                  'Login as:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoleButton("employee", "Employee"),
                      const SizedBox(width: 15),
                      _buildRoleButton("manager", "Manager"),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  margin: EdgeInsets.only(left:25, right:25),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  margin: EdgeInsets.only(left: 25, right: 25, bottom: 5),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  height: 25, // reserves space so button doesn't move
                  child: _errorMessage == null
                      ? const SizedBox.shrink()
                      : Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 15),
                  ),
                ),


                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: Text('Login',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white
                          )
                      )
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),


                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          )
                        ),


                        TextButton(
                            onPressed: () => goToPage(context, CreateAccountPage()),
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                              minimumSize: WidgetStateProperty.all(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Create Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.green,
                                )
                            )
                        ),


                      ],
                    ),
                  ),
                )

              ],
            ),
          ),
        )
    );
  }
}
