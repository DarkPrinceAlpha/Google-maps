import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late LatLng cuurentPostion;
  bool _buildErrorOrMap = true;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _marker = [];
  final List<Marker> _list = [
    const Marker(markerId: MarkerId('1'), position: LatLng(29.3544, 71.6911)),
    const Marker(
      markerId: MarkerId('2'),
      position: LatLng(30.1575, 71.5249),
    ),
    const Marker(
        infoWindow: InfoWindow(title: 'okay'),
        markerId: MarkerId('3'),
        position: LatLng(29.5467, 71.6276))
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentPostion();
    _marker.addAll(_list);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _buildErrorOrMap
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                onMapCreated: (controller) {
                  _controller.complete(controller);
                },
                markers: Set<Marker>.of(_marker),
                myLocationEnabled: true,
                compassEnabled: true,
                initialCameraPosition:
                    CameraPosition(target: cuurentPostion, zoom: 13)),
        floatingActionButton: FloatingActionButton(onPressed: () async {
          GoogleMapController controller = await _controller.future;
          controller.animateCamera(
              CameraUpdate.newCameraPosition(const CameraPosition(
                  zoom: 13,
                  target: LatLng(
                    30.1575,
                    71.5249,
                  ))));
          setState(() {});
        }),
      ),
    );
  }

  void _getCurrentPostion() async {
    PermissionStatus permitted = await Permission.location.request();
    if (permitted == PermissionStatus.granted) {
      Position position = await GeolocatorPlatform.instance.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.reduced));
      setState(() {
        _buildErrorOrMap = false;
        cuurentPostion = LatLng(position.latitude, position.longitude);
      });
    } else {
      log('No permission');
    }
  }
}
