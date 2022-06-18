import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_flutter_app/directions.dart';
import 'package:map_flutter_app/directions_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(39.7471352, 39.4688891),
    zoom: 11.5,
  );

  late GoogleMapController googleMapController;
  Marker? markerOrigin, markerDestination;
  Directions? _info;

  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text(
          'Maps App',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          if (markerOrigin != null)
            TextButton(
                onPressed: () {
                  googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: markerOrigin!.position,
                        zoom: 14.5,
                        tilt: 50.0,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  primary: Colors.green,
                  textStyle: TextStyle(fontWeight: FontWeight.w600),
                ),
                child: Text('Origin')),
          if (markerDestination != null)
            TextButton(
                onPressed: () {
                  googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: markerDestination!.position,
                        zoom: 14.5,
                        tilt: 50.0,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  primary: Colors.blue,
                  textStyle: TextStyle(fontWeight: FontWeight.w600),
                ),
                child: Text('Dest')),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              googleMapController = controller;
            },
            markers: {
              if (markerOrigin != null) markerOrigin!,
              if (markerDestination != null) markerDestination!,
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points: _info!.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                )
            },
            onLongPress: addMarker,
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.center_focus_strong),
        onPressed: () {
          googleMapController.animateCamera(
            _info != null
                ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
                : CameraUpdate.newCameraPosition(_initialCameraPosition),
          );
        },
      ),
    );
  }

  Future<void> addMarker(LatLng pos) async {
    if (markerOrigin == null ||
        (markerOrigin != null && markerDestination != null)) {
      setState(() {
        markerOrigin = Marker(
          markerId: MarkerId('Origin'),
          infoWindow: InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        markerDestination = null;
        _info = null;
      });
    } else {
      setState(() {
        markerDestination = Marker(
          markerId: MarkerId('Destination'),
          infoWindow: InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });

      final directions = await DirectionsRepository()
          .getDirections(origin: markerOrigin!.position, destination: pos);
      setState(() {
        _info = directions;
      });
    }
  }
}
