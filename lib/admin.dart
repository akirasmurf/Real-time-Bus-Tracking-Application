import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("All Users"),
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance.collection("users").get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                List users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Card(
                      color: users[index]["isEnabled"]
                          ? Color.fromARGB(255, 187, 255, 189)
                          : Color.fromARGB(255, 255, 122, 122),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              users[index]["dpURL"] != "-"
                                  ? users[index]["dpURL"]
                                  : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(users[index]["name"]),
                        subtitle: Text(users[index]["uid"]),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.disabled_by_default,
                          ),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Disable Account"),
                                  content: Text(users[index]["isEnabled"]
                                      ? "Do you wish to disable the user :- \n${Text(users[index]["name"])}?"
                                      : "Do you wish to enable the user :- \n${Text(users[index]["name"])}?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(users[index]["uid"])
                                              .update({
                                            "isEnabled": !users[index]
                                                ["isEnabled"],
                                          }).then((value) {
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          });
                                        },
                                        child: Text(users[index]["isEnabled"]
                                            ? "Disable"
                                            : "Enable"))
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }
}
