import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import '../helpers/shared_prefs.dart';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:location/location.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

class HomeManagement extends StatefulWidget {
  const HomeManagement({Key? key}) : super(key: key);

  @override
  State<HomeManagement> createState() => _HomeManagementState();
}

class _HomeManagementState extends State<HomeManagement> {
  String? _message;
  bool _isSending = false;
  LatLng latLng = getLatLngFromSharedPrefs();
  LatLng loc = getLatLngFromSharedPrefs();
  late CameraPosition _initialCameraPosition;
  late CameraPosition _currentCameraPosition;
  late MapboxMapController controller;
  IOWebSocketChannel? channel;
  Location _location = Location();
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = CameraPosition(target: latLng, zoom: 15);
    channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');
  }

  _onMapCreated(MapboxMapController controller) async {
    this.controller = controller;
  }

  void _startSending() async {
    setState(() {
      _isSending = true;
    });
    // Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!_isSending) {
      // timer.cancel();
      return;
    }
    String? msg;
    _locationData = await _location.getLocation();

    loc = LatLng(_locationData!.latitude!.toDouble(),
        _locationData!.longitude!.toDouble());

    _currentCameraPosition = CameraPosition(target: loc, zoom: 15);
    msg = loc.toString();
    channel?.sink.add(loc.toString());
  }

  void _stopSending() {
    setState(() {
      _isSending = false;
    });
  }

  void sendMsg(msg) {
    // IOWebSocketChannel? channel;
    // try {
    //   print(_message);
    //   // Connect to our backend.
    //   channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');
    // } catch (e) {
    //   // If there is any error that might be because you need to use another connection.
    //   print("Error on connecting to websocket: " + e.toString());
    // }
    // Send message to backend
    // channel?.sink.add(msg);

    // Listen for any message from backend
    // channel?.stream.listen((event) {
    //   // Just making sure it is not empty
    //   if (event!.isNotEmpty) {
    //     print(event);
    //     // Now only close the connection and we are done here!
    //     channel!.sink.close();
    //   }
    // });
  }

  _onStyleLoadedCallback() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('USER APP'),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: MapboxMap(
                accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN'],
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                minMaxZoomPreference: const MinMaxZoomPreference(14, 17),
              ),
            ),
            StreamBuilder(
              stream: channel!.stream,
              builder: (context, snapshot) {
                String driverData = snapshot.data.toString();
                print(driverData);
                return Text(snapshot.hasData ? driverData : '');
              },
            ),
          ],
        )),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(_initialCameraPosition));
                },
                child: Icon(Icons.my_location),
              ),
            ),
            Positioned(
              bottom: 80.0,
              left: 20.0,
              child: FloatingActionButton(
                onPressed: () {
                  // Add your onPressed logic here
                  _message = "Hello World!";
                  _message = latLng.toString();
                  if (_message!.isNotEmpty) {
                    if (_isSending == false) {
                      _isSending = true;
                      _startSending();
                    } else {
                      _isSending = false;
                      _stopSending();
                    }
                    // sendMsg(_message);
                  }
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(_currentCameraPosition));
                },
                child: Icon(Icons.back_hand_outlined),
              ),
            ),
          ],
        ));
  }
}
