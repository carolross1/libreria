import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorWidget extends StatefulWidget {
  const GeolocatorWidget({Key? key}) : super(key: key);

  @override
  State<GeolocatorWidget> createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
  LatLng _currentPosition = LatLng(0, 0);
  bool _isLoading = true;

  // Ubicación fija (por ejemplo, Ciudad de México)
  final LatLng _fixedLocation = LatLng(21.152622154171187, -100.93904392926505);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  Future<bool> _handlePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 157, 176, 255),
        title: Text(
          'TÚ UBICACIÓN',
          style: TextStyle(
            fontFamily: 'DancingScript',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();  
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _currentPosition, 
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    // Marcador para la ubicación actual
                    Marker(
                      point: _currentPosition,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 157, 176, 255),
                        size: 50,
                      ),
                    ),
                    // Marcador para la ubicación fija
                    Marker(
                      point: _fixedLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.store,
                        color: Color.fromARGB(255, 157, 176, 255),
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
