import 'package:flutter/painting.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:background_location/background_location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';

const List<Color> _kDefaultRainbowColors = const [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';

  @override
  void initState() {
    super.initState();
    BackgroundLocation.setAndroidNotification(
      title: 'Patrol',
      message: 'Background location updating',
      icon: '@mipmap/ic_launcher',
    );
    Timer.periodic(new Duration(seconds: 1), (timer) {
      uploadCurrentLocation();
    });
  }

  void uploadCurrentLocation() async {
    var url = Uri.parse('http://192.168.1.72:3000/count');
    var response = await http.get(url);
    await BackgroundLocation.startLocationService(distanceFilter: 0.3);
    BackgroundLocation.getLocationUpdates((location) async {
      setState(() {
        latitude = location.latitude.toString();
        longitude = location.longitude.toString();
        accuracy = location.accuracy.toString();
        altitude = location.altitude.toString();
        bearing = location.bearing.toString();
        speed = location.speed.toString();
        time = DateTime.fromMillisecondsSinceEpoch(location.time!.toInt())
            .toString();
      });
      var response2 = await http.post(url, body: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      });
      print(response2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tutorial',
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white.withOpacity(0),
          title: Center(
            child: Text('Flutter Tutorial'),
          ),
        ),
        body: Center(
            child: Container(
          alignment: Alignment.center,
          width: 200,
          height: 200,
          child: Column(
            children: [
              Text(
                'Patrol Started. Press back to stop patrolling.',
                textAlign: TextAlign.center,
              ),
              Container(
                width: 50,
                height: 30,
                child: LoadingIndicator(
                  colors: [Colors.grey],
                  indicatorType: Indicator.values[16],
                  strokeWidth: 1,
                  // pathBackgroundColor: Colors.black45,
                ),
              )
            ],
          ),
        )),
      ),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  void getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      print('This is current Location ' + location.toMap().toString());
    });
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}
