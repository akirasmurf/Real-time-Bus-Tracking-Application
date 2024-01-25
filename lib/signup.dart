import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _controller = TextEditingController();
  void fbupdate(name) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "uid": "${FirebaseAuth.instance.currentUser!.uid}",
      "name": "$name",
      "dpURL": "-",
      "isEnabled": true
    }).then((value) => Navigator.pushReplacementNamed(context, '/home'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("User Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            CircleAvatar(
              radius: 64,
              child: ClipOval(
                  // borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.fitHeight,
              )),
            ),
            SizedBox(
              height: 60,
            ),
            TextField(
              controller: _controller,
              obscureText: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  FirebaseAuth.instance.currentUser!
                      .updateDisplayName(_controller.text)
                      .then((value) => fbupdate(_controller.text));
                }
              },
              child: Text("Proceed"),
            ),
          ],
        ),
      ),
    );
  }
}
