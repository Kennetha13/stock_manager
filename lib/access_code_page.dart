import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stock_mananger_1/employee_dash.dart';
import 'navigator_helper.dart';

class AccessCodePage extends StatefulWidget {
  const AccessCodePage({super.key});

  @override
  State<AccessCodePage> createState() => _AccessCodePageState();
}

class _AccessCodePageState extends State<AccessCodePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _loading = false;
  String? _errorMessage;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _joinCompanyWithCode() async {
    final code = _controller.text.trim(); // case-sensitive like you said

    if (code.length != 4) {
      setState(() => _errorMessage = "Enter a 4-character access code.");
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _errorMessage = "You must be logged in first.");
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // 1) Look up companyId using accessCodes/{CODE}
      final codeDoc = await _db.collection("accessCodes").doc(code).get();
      final codeData = codeDoc.data();
      if (codeData == null) {
        setState(() => _errorMessage = "Invalid access code.");
        return;
      }

      final companyId = (codeData["companyId"] ?? "").toString();
      if (companyId.isEmpty) {
        setState(() => _errorMessage = "Invalid access code.");
        return;
      }

      // 2) Get user's profile (name/email) for convenience
      final userDoc = await _db.collection("users").doc(user.uid).get();
      final userProfile = userDoc.data() ?? {};
      final name = (userProfile["name"] ?? "").toString();
      final email = (userProfile["email"] ?? user.email ?? "").toString();

      // 3) Update user profile to attach them to company (so they never re-enter code)
      await _db.collection("users").doc(user.uid).set({
        "companyId": companyId,
        "role": "employee",
        "email": email,
        if (name.isNotEmpty) "name": name,
        "joinedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4) Add employee into company roster
      await _db
          .collection("companies")
          .doc(companyId)
          .collection("employees")
          .doc(user.uid)
          .set({
        "name": name,
        "email": email,
        "role": "employee",
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ✅ Avoid BuildContext across async gaps
      if (!mounted) return;

      // 5) Navigate
      goToPage(context, EmployeeDashPage());
    } catch (_) {
      setState(() => _errorMessage = "Something went wrong. Try again.");
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;

    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Container(
          width: 350,
          height: 520, // slightly taller to fit error text cleanly
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFC8E6C9),
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.green,
                    size: 85,
                  ),
                ),
              ),
              const Text(
                'Enter Access Code',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: const Text(
                  'Please enter the code provided by your manager to access your business',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Invisible TextField
                    Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLength: 4,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(counterText: ""),
                      ),
                    ),

                    // Decorative boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final char = index < code.length ? code[index] : "";

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          height: 80,
                          width: 65,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Text(
                            char,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Access code is case-sensitive',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),

              // Error message (reserved space so button doesn't move)
              Container(
                height: 20,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: _errorMessage == null
                    ? const SizedBox.shrink()
                    : Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _loading ? null : _joinCompanyWithCode,
                  child: _loading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Continue',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}