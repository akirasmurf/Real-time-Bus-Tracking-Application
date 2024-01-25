import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:developer' as console;

import 'package:buslog/constants.dart';
import 'package:geolocator/geolocator.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timelines/timelines.dart';
import 'package:http/http.dart' as http;

class SimpleView extends StatefulWidget {
  SimpleView({Key? key}) : super(key: key);

  @override
  State<SimpleView> createState() => _SimpleViewState();
}

class _SimpleViewState extends State<SimpleView> {
  String googleApiKey = 'AIzaSyBFmMyVU5XZSAVu1CM5lQhHQqTdbYEzBYo';
  LatLng busLocation = LatLng(0, 0);
  int lastID = 0;
  int destID = 0;
  List<Stops> busStop = [
    Stops(id: 0, name: "KTM Batu Tiga", coordinate: loopPoint),
    Stops(id: 1, name: "Giant", coordinate: stop1),
    Stops(id: 2, name: "Aeon Shah Alam", coordinate: stop2),
    Stops(id: 3, name: "MSU Entrance", coordinate: stop3),
    Stops(id: 4, name: "Lotus's", coordinate: stop4),
    Stops(id: 5, name: "Aquatic Swimming Pool Shah Alam", coordinate: stop5),
    Stops(id: 6, name: "LRT 3", coordinate: stop6),
  ];
  List<Stops> timelineList = [
    Stops(id: 0, name: "KTM Batu Tiga", coordinate: loopPoint),
    Stops(id: 1, name: "Giant", coordinate: stop1),
    Stops(id: 2, name: "Aeon Shah Alam", coordinate: stop2),
    Stops(id: 3, name: "MSU Entrance", coordinate: stop3),
    Stops(id: 4, name: "Lotus's", coordinate: stop4),
    Stops(id: 5, name: "Aquatic Swimming Pool Shah Alam", coordinate: stop5),
    Stops(id: 6, name: "LRT 3", coordinate: stop6),
    Stops(id: 99, name: "Bus 🚌", coordinate: LatLng(0, 0))
  ];

  TextEditingController myPickup = TextEditingController();
  void location() async {
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('/bus_coordinate');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      var myLoc = LatLng(data["Hardware"]["Latitude"]["data"],
          data["Hardware"]["Longitude"]["data"]);
      setState(() {
        lastID = data["coordinate"]["last_stop"];

        busLocation = myLoc;
      });
      distanceCalulator(myLoc);
    });
  }

  void distanceCalulator(LatLng myLoc) {
    var nearest = 0.0;
    var nearestName = "";
    List<Distance> distance = [];
    for (var stops in busStop) {
      distance.add(Distance(
          id: stops.id,
          name: stops.name,
          distance: calculateDistance(myLoc, stops.coordinate)));
      // print(stops.name +
      //     " " +
      //     calculateDistance(myLoc, stops.coordinate).toString());
    }
    distance.sort((a, b) => a.distance.compareTo(b.distance));
    for (var element in distance) {
      if (element.distance <= 0.02) {
        DatabaseReference ref =
            FirebaseDatabase.instance.ref('/bus_coordinate/coordinate');
        ref.update({"last_stop": element.id});
        timelineList.removeWhere((element) => element.id == 99);
        print(timelineList);
        print("Elemnt ID  ${element.id}");
        timelineList.insert(element.id + 1,
            Stops(id: 99, name: "Bus 🚌", coordinate: LatLng(0, 0)));
      } else {
        timelineList.removeWhere((element) => element.id == 99);
        print(timelineList);
        print("Elemnt ID  ${element.id}");
        timelineList.insert(
            lastID, Stops(id: 99, name: "Bus 🚌", coordinate: LatLng(0, 0)));
      }
    }
  }

  Future<void> mapsRequest(int myid) async {
    int totalstops = 0;
    int lastTemp = lastID;
    int myTemp = myid;
    List stopsID = [];
    String url = "";

    // wait till loop
    while (true) {
      if (lastTemp == myid) {
        break;
      }
      if (lastTemp > 5) {
        lastTemp = -1;
      }
      lastTemp++;
      stopsID.add(lastTemp);
      totalstops++;
    }

    String vias = viaListGenerator(stopsID);
    if (stopsID.length > 1) {
      url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${busLocation.latitude},${busLocation.longitude}&destination=${loopPoint.latitude},${loopPoint.longitude}&waypoints=$vias&key=$googleApiKey';
    } else {
      url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${busLocation.latitude},${busLocation.longitude}&destination=${busStop.where((element) => element.id == myid).first.coordinate.latitude},${busStop.where((element) => element.id == myid).first.coordinate.longitude}&key=$googleApiKey';
    }

    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    var duration =
        ((jsonResponse["routes"][0]["legs"][0]["duration"]["value"]) / 60)
            .round();

    showAlert(duration, stopsID);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void showAlert(int duration, List stops) async {
    Position myPosition = await _determinePosition();
    List<Distance> mydistance = [];
    for (var e in busStop) {
      mydistance.add(
        Distance(
          id: e.id,
          name: e.name,
          distance: calculateDistance(
            e.coordinate,
            LatLng(myPosition.latitude, myPosition.longitude),
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        var allstops = "";
        for (var stop in stops) {
          allstops +=
              "\n${busStop.where((element) => element.id == stop).first.name}";
        }
        var mydistanceStr = "";
        for (var e in mydistance) {
          mydistanceStr += "\n${e.name}: ${e.distance.toStringAsFixed(2)} KM";
        }
        return AlertDialog(
          title: Text("Bus Location"),
          content: Text(
              "Distance From Stops\n$mydistanceStr\n\nAll Stops:-\n$allstops\n\nDuration:-\n$duration mins"),
        );
      },
    );
  }

  String viaListGenerator(List stops) {
    String vias = "";
    for (var stop in stops) {
      if (stops.first == stop) {
        vias =
            'via:${busStop.where((element) => element.id == stop).first.coordinate.latitude}%2C${busStop.where((element) => element.id == stop).first.coordinate.longitude}';
      } else {
        vias =
            '$vias|via:${busStop.where((element) => element.id == stop).first.coordinate.latitude}%2C${busStop.where((element) => element.id == stop).first.coordinate.longitude}';
      }
    }

    return vias;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Route View"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
            child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Timeline.tileBuilder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              builder: TimelineTileBuilder.fromStyle(
                indicatorStyle: IndicatorStyle.outlined,
                connectorStyle: ConnectorStyle.dashedLine,
                endConnectorStyle: ConnectorStyle.solidLine,
                contentsAlign: ContentsAlign.alternating,
                contentsBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(timelineList[index].name),
                ),
                itemCount: 8,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: DropdownMenu(
                  controller: myPickup,
                  hintText: "Where to Pick Me Up?",
                  dropdownMenuEntries: busStop
                      .map((e) =>
                          DropdownMenuEntry(value: e.name, label: e.name))
                      .toList()),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (myPickup.text.isNotEmpty) {
                    mapsRequest(busStop
                        .where((element) => element.name == myPickup.text)
                        .first
                        .id);
                  }
                },
                child: Text("Calculate"),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class Distance {
  int id;
  String name;
  double distance;
  Distance({required this.id, required this.name, required this.distance});
}

class Stops {
  int id;
  String name;
  LatLng coordinate;
  Stops({required this.id, required this.name, required this.coordinate});
}

double calculateDistance(LatLng coor1, LatLng coor2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((coor2.latitude - coor1.latitude) * p) / 2 +
      c(coor1.latitude * p) *
          c(coor2.latitude * p) *
          (1 - c((coor2.longitude - coor1.longitude) * p)) /
          2;
  return 12742 * asin(sqrt(a));
}
