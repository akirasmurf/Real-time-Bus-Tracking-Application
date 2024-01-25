import 'package:buslog/admin.dart';
import 'package:buslog/mapsView.dart';
import 'package:buslog/profile.dart';
import 'package:buslog/signup.dart';
import 'package:buslog/simpleViw.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  var _currIdx = 1;
  List<Widget> _pages = [SimpleView(), Home(), Profile(), AdminPage()];

  bool paywall = false;
  @override
  void initState() {
    super.initState();
    getDisabled();
  }

  void getDisabled() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      try {
        if (!value.data()!["isEnabled"]) {
          Navigator.popAndPushNamed(context, "/disabled");
        }
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red,
        unselectedItemColor: const Color.fromARGB(255, 35, 29, 29),
        selectedItemColor: Colors.white,
        onTap: (value) {
          setState(() {
            _currIdx = value;
            print(_currIdx);
          });
        },
        currentIndex: _currIdx,
        items: FirebaseAuth.instance.currentUser!.uid !=
                "NQyDXQifyxgo0R93EOY6OgkMKq92"
            ? [
                BottomNavigationBarItem(
                    icon: Icon(Icons.route), label: "Route"),
                BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profile"),
              ]
            : [
                BottomNavigationBarItem(
                    icon: Icon(Icons.route), label: "Route"),
                BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profile"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.admin_panel_settings), label: "Admin"),
              ],
      ),
      body: _pages[_currIdx],
    );
  }
}
