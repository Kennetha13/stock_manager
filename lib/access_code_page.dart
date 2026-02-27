import'package:flutter/material.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;


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
            children: [
              Container(
                margin: EdgeInsets.all(20),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFC8E6C9),
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.green,
                    size: 85,
                  ),
                ),
              ),
              Text(
                'Enter Access Code',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  'Please enter the code provided by your manager to access your business',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 30),

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
                          String char = index < code.length ? code[index] : "";

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 80,
                            width: 65,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green,
                                width: 2,
                              ),
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

              const SizedBox(height: 30),

              Text(
                'Access code is case-sensitive',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )
                    ),
                    onPressed: () => goToPage(context, EmployeeDashPage()),
                    child: Text('Continue',
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
      ),
    );
  }
}