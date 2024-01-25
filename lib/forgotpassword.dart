import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool obscure = true;
  bool error = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 80,
                    child: ClipOval(
                        // borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                      "assets/logo.png",
                      fit: BoxFit.fitHeight,
                    )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  "Forgotten Password",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                    "Provide your email and we will send you a link to reset your password"),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(label: Text("Email")),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/forgot");
                        },
                        child: Text("Forgot Password?"),
                      ),
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: OutlinedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            error = false;
                          });

                          FirebaseAuth.instance
                              .sendPasswordResetEmail(
                            email: emailController.text,
                          )
                              .then((value) {
                            Navigator.of(context).pushNamed("/sign-in");
                          }).onError((error, stackTrace) {
                            setState(() {
                              error = true;
                            });
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill input')),
                          );
                        }
                      },
                      child: Text("Reset password"))),
              error
                  ? Text(
                      "Error occured during Sign In. Please check your credentials")
                  : Container(),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Go back"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
