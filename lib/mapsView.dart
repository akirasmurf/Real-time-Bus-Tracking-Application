import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:buslog/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late StreamSubscription<Position> positionStream;
  LatLng _myLocation = LatLng(0, 0);
  GoogleMapController? mapController;
  final List<Marker> _markers = [];
  LatLng _busLocation = const LatLng(3.075804538445285, 101.55977706444797);
  late ByteData imageData;
  late ByteData mydata;

  // ...
  @override
  void initState() {
    super.initState();
    rootBundle
        .load('assets/bus.png')
        .then((data) => setState(() => this.imageData = data));
    rootBundle
        .load('assets/my.png')
        .then((data) => setState(() => this.mydata = data));
    _addMarkers();
    getlocation();
    // _fetchRoutePoints();
  }

  void getlocation() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        setState(() {
          _myLocation = LatLng(position.latitude, position.longitude);
          _markers.removeAt(0);
          _markers.insert(
              0,
              Marker(
                markerId: const MarkerId('my'),
                position: _myLocation,
                icon: BitmapDescriptor.fromBytes(mydata.buffer.asUint8List()),
              ));
        });
        print(_myLocation);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    positionStream.cancel();
    super.dispose();
  }

  void _addMarkers() async {
    // String imgurl = "https://cdn-icons-png.flaticon.com/512/3448/3448339.png";
    // http.Response response = await http.get(Uri.parse(imgurl));

    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('/bus_coordinate/Hardware');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _busLocation =
            LatLng(data["Latitude"]["data"], data["Longitude"]["data"]);
        print("My Bus ${_busLocation}");
        _markers.removeLast();
        _markers.add(Marker(
          markerId: const MarkerId('bus'),
          position: _busLocation,
          icon: BitmapDescriptor.fromBytes(imageData.buffer.asUint8List()),
        ));
      });
    });
    _markers.add(Marker(
      markerId: MarkerId('my'),
      position: _myLocation,
      infoWindow: InfoWindow(title: 'My Location'),
    ));
    _markers.add(const Marker(
      markerId: MarkerId('ktm'),
      position: LatLng(3.075804538445285, 101.55977706444797),
      infoWindow: InfoWindow(title: 'KTM Batu Tiga'),
    ));
    _markers.add(const Marker(
      markerId: MarkerId('giant'),
      position: LatLng(3.085293215073102, 101.54984708592612),
      infoWindow: InfoWindow(title: 'Giant'),
    ));
    _markers.add(const Marker(
      markerId: MarkerId('aeon'),
      position: LatLng(3.076574091285064, 101.54950786759026),
      infoWindow: InfoWindow(title: 'Aeon Shah Alam'),
    ));
    _markers.add(const Marker(
      markerId: MarkerId('msu'),
      position: LatLng(3.077659382775359, 101.55233198338054),
      infoWindow: InfoWindow(title: 'MSU Entrance'),
    ));

    _markers.add(const Marker(
      markerId: MarkerId('lotus'),
      position: LatLng(3.072447229626144, 101.53916157907116),
      infoWindow: InfoWindow(title: 'Lotus'),
    ));
    _markers.add(const Marker(
      markerId: MarkerId('aquatic'),
      position: LatLng(3.0743006486504054, 101.53745569414887),
      infoWindow: InfoWindow(title: 'Aquatic Swimming Pool Shah Alam'),
    ));
    _markers.add(const Marker(
      markerId: MarkerId('lrt'),
      position: LatLng(3.078618138250066, 101.54243387406741),
      infoWindow: InfoWindow(title: 'LRT 3'),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('bus'),
      position: _busLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));
  }

  // Future<void> _fetchRoutePoints() async {
  // String googleApiKey = 'AIzaSyBFmMyVU5XZSAVu1CM5lQhHQqTdbYEzBYo';
  // LatLng loopPoint = const LatLng(3.075804538445285, 101.55977706444797);
  // LatLng stop1 = const LatLng(3.085293215073102, 101.54984708592612);
  // LatLng stop2 = const LatLng(3.076574091285064, 101.54950786759026);
  // LatLng stop3 = const LatLng(3.077659382775359, 101.55233198338054);
  // LatLng stop4 = const LatLng(3.072447229626144, 101.53916157907116);
  // LatLng stop5 = const LatLng(3.0743006486504054, 101.53745569414887);
  // LatLng stop6 = const LatLng(3.078618138250066, 101.54243387406741);

  // String url = 'https://maps.googleapis.com/maps/api/directions/json?' +
  //     'origin=${loopPoint.latitude},${loopPoint.longitude}&' +
  //     'destination=${loopPoint.latitude},${loopPoint.longitude}&' +
  //     'waypoints=via:${stop1.latitude}%2C${stop1.longitude}' +
  //     '|via:${stop2.latitude}%2C${stop2.longitude}' +
  //     '|via:${stop3.latitude}%2C${stop3.longitude}' +
  //     '|via:${stop4.latitude}%2C${stop4.longitude}' +
  //     '|via:${stop5.latitude}%2C${stop5.longitude}' +
  //     '|via:${stop6.latitude}%2C${stop6.longitude}&' +
  //     'key=$googleApiKey';

  //   http.Response response = await http.get(Uri.parse(url));
  //   Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //   log(response.body);
  //   String encodedPolyline =
  //       jsonResponse['routes'][0]['overview_polyline']['points'];
  //   List<LatLng> decodedPolyline = _decodePolyline(encodedPolyline);
  //   log(decodedPolyline.toString());
  // }

  // ...

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Fetch the route points between bus stops
    // _fetchRoutePoints();

    // Move camera to initial position
    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(3.076574091285064, 101.54950786759026),
          zoom: 14.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Route (Map)'),
        centerTitle: true,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: {..._markers},
        polylines: {
          Polyline(
            polylineId: const PolylineId('route1'),
            color: Colors.blue,
            width: 5,
            points: routePoints,
          ),
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7840, -122.4088),
          zoom: 14.0,
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                // Simulate movement of bus location
                _busLocation = LatLng(_busLocation.latitude + 0.0001,
                    _busLocation.longitude + 0.0001);

                // Move camera to new bus location
                mapController?.animateCamera(
                  CameraUpdate.newLatLng(_busLocation),
                );
              });
            },
            child: const Icon(Icons.directions_bus),
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
