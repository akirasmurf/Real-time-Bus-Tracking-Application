import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DisabledAccount extends StatefulWidget {
  DisabledAccount({Key? key}) : super(key: key);

  @override
  State<DisabledAccount> createState() => _DisabledAccountState();
}

class _DisabledAccountState extends State<DisabledAccount> {
  @override
  Widget build(BuildContext context) {
    final Uri call = Uri(
      scheme: 'tel',
      path: '+60122429110',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Disabled",
          style: TextStyle(color: Colors.red),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                " Account Disabled by Admin. Please Contact Admin for further information!",
                style: TextStyle(color: Colors.red, fontSize: 26),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  launchUrl(call);
                },
                child: Text("Contact Admin"))
          ],
        ),
      ),
    );
  }
}
