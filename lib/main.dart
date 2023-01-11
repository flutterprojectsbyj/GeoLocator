/*
 * Copyright (C) 2021 - JMPFBMX
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
      ),
      home: const MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool gpsStatus = false;
  bool hasPermission = true;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  String deniedPermission = "";
  String gpsDisable = "";
  late StreamSubscription<Position> positionStream;
  late List<Placemark> placeMarks;
  String placeName = "";

  @override
  void initState() {
    checkGps();
    super.initState();
  }

  checkGps() async {
    gpsStatus = await Geolocator.isLocationServiceEnabled();

    if (gpsStatus) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        hasPermission = false;
        if (permission == LocationPermission.denied) {
          deniedPermission = "Location permissions are denied";
          hasPermission = false;
        } else if (permission == LocationPermission.deniedForever) {
          deniedPermission = "Location permissions are permanently denied";
          hasPermission = false;
        }
      }

      if (hasPermission) {
        setState(() {});
        getLocation();
      }
    } else {
      gpsDisable = "GPS Service is not enabled, turn on GPS location";
    }

    setState(() {});
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    lat = position.latitude.toString();
    long = position.longitude.toString();
    placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    placeName = "${placeMarks.first.administrativeArea}, ${placeMarks.first.street}";

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("GPS Locator"),
            centerTitle: true,
        ),
        body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Visibility(visible: !gpsStatus, child: Text(gpsDisable)),
                Visibility(visible: !hasPermission, child: Text(deniedPermission)),
                Text("Latitude, Longitude:\n$lat, $long\n", style: const TextStyle(fontSize: 20,), textAlign: TextAlign.center,),
                Text("You are right now at: \n$placeName", style: const TextStyle(fontSize: 20), textAlign: TextAlign.center,),
              ],
            ),
        ),
    );
  }
}
