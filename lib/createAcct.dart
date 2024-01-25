import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool obscure = true;
  bool obscure2 = true;

  bool error = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();

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
                  "Sign In",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Text("Already have an account?"),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/sign-in");
                        },
                        child: Text("Sign In"))
                  ],
                ),
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
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    label: Text("Password"),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                      icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextFormField(
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Password do not match';
                    }
                    return null;
                  },
                  controller: passwordController2,
                  obscureText: obscure2,
                  decoration: InputDecoration(
                    label: Text("Confirm Password"),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscure2 = !obscure2;
                        });
                      },
                      icon: Icon(
                          obscure2 ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: OutlinedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            error = false;
                          });

                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text)
                              .then((value) {
                            Navigator.of(context).pushNamed("/signup");
                          }).onError((errorMSG, stackTrace) {
                            setState(() {
                              error = true;
                            });
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Auth Error"),
                                  content: Text(errorMSG.toString()),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Ok"))
                                  ],
                                );
                              },
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill input')),
                          );
                        }
                      },
                      child: Text("Register"))),
            ],
          ),
        ),
      ),
    );
  }
}
