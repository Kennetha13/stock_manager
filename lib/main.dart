import 'package:flutter/material.dart';
import 'navigator_helper.dart';
import 'create_account_page.dart';
import 'manager_dash.dart';
import 'access_code_page.dart';
import 'employee_dash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Stock Manager',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'LOGIN'),
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
  // ✅ UI toggle (used for Option B role-check)
  String selectedRole = "employee";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryAutoLogin() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ Option B routing
      await _routeAfterLoginWithRoleCheck();
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

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

      // ✅ Option B routing
      await _routeAfterLoginWithRoleCheck();
    } on FirebaseAuthException catch (e) {
      debugPrint("AUTH ERROR CODE: ${e.code}");
      debugPrint("AUTH ERROR MESSAGE: ${e.message}");

      setState(() {
        _errorMessage = 'Wrong Password or Email';
      });
    } catch (_) {
      setState(() {
        _errorMessage = "Something went wrong. Try again.";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// ✅ Option B: checks Firestore role vs selectedRole.
  /// - If mismatch: show error + sign out (prevents auto-login loop)
  /// - If match: route normally
  Future<void> _routeAfterLoginWithRoleCheck() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _db.collection("users").doc(user.uid).get();
    final data = doc.data();

    // Auth exists but Firestore profile missing
    if (data == null) {
      setState(() {
        _errorMessage = "Account not found. Please create an account.";
      });
      await _auth.signOut(); // prevent auto-login loop
      return;
    }

    final role = (data["role"] ?? "").toString(); // "employee" or "manager"
    final companyId = (data["companyId"] ?? "").toString();

    // ✅ DENY if the toggle doesn't match the real role
    if (selectedRole != role) {
      setState(() {
        _errorMessage =
        "This account is a $role account. Please select $role and try again.";
      });
      await _auth.signOut(); // keep flow clean
      return;
    }

    if (!mounted) return;

    // ✅ Route based on the real role
    if (role == "manager") {
      goToPage(context, const ManagerDashPage());
      return;
    }

    if (role == "employee") {
      if (companyId.isNotEmpty) {
        goToPage(context, const EmployeeDashPage());
      } else {
        goToPage(context, const AccessCodePage());
      }
      return;
    }

    setState(() => _errorMessage = "Invalid account configuration.");
    await _auth.signOut();
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
          height: 660,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: const Icon(
                  Icons.shelves,
                  color: Colors.green,
                  size: 100.0,
                ),
              ),
              const Text(
                'Stock Manager',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text(
                'Manage your inventory with ease',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Login as:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
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
                margin: const EdgeInsets.only(left: 25, right: 25),
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
                margin: const EdgeInsets.only(left: 25, right: 25, bottom: 5),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),

              // Error reserved space so button doesn't move
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                height: 32,
                alignment: Alignment.center,
                child: _errorMessage == null
                    ? const SizedBox.shrink()
                    : Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 20),
                width: 300,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Login',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
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
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () => goToPage(context, CreateAccountPage()),
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}