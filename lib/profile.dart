import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as UIAuth;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var providers = [UIAuth.EmailAuthProvider()];

  @override
  Widget build(BuildContext context) {
    final Uri call = Uri(
      scheme: 'tel',
      path: '999',
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          launchUrl(call);
        },
        child: Icon(Icons.emergency),
      ),
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
// Pick an image.
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  final storageRef = FirebaseStorage.instance.ref();
                  final dpref = storageRef
                      .child("${FirebaseAuth.instance.currentUser!.uid}.jpg");
                  File file = File(image.path);
                  try {
                    var upload = await dpref.putFile(file);
                    var dwurl = await upload.ref.getDownloadURL();
                    await FirebaseAuth.instance.currentUser!
                        .updatePhotoURL(dwurl)
                        .then((value) {
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({"dpURL": dwurl});
                    });
                  } on FirebaseException catch (e) {
                    print(e.message);
                  }
                }
              },
              icon: Icon(Icons.image))
        ],
        centerTitle: true,
      ),
      body: UIAuth.ProfileScreen(
        providers: providers,
        actions: [
          UIAuth.SignedOutAction((context) {
            Navigator.pushReplacementNamed(context, '/sign-in');
          }),
        ],
      ),
    );
  }
}
