import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class OpenstreetmapScreen extends StatefulWidget {
  const OpenstreetmapScreen({super.key});

  @override
  State<OpenstreetmapScreen> createState() => _OpenstreetmapScreenState();
}

class _OpenstreetmapScreenState extends State<OpenstreetmapScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = true;
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (!await _checktheRequestPermissions()) return;

    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          isLoading = false;
        });
      }
    });
  }

  Future<void> fetchCoordinates(String location) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);

          setState(() {
            _destination = LatLng(lat, lon);
            isLoading = false;
          });

          _mapController.move(_destination!, 14);
          await fetchRoute();
        } else {
          setState(() {
            isLoading = false;
          });
          errorMessage('Localización no encontrada');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        errorMessage('Error al buscar localización');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      errorMessage('Error de conexión');
    }
  }

  Future<void> fetchRoute() async {
    if (_currentLocation == null || _destination == null) {
      errorMessage('No se puede calcular ruta');
      return;
    }

    try {
      final url = Uri.parse(
        "http://router.project-osrm.org/route/v1/driving/"
        "${_currentLocation!.longitude},${_currentLocation!.latitude};"
        "${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          _decodePolyline(geometry);
        } else {
          errorMessage('No se encontró ruta');
        }
      } else {
        errorMessage('Error al encontrar la ruta');
      }
    } catch (e) {
      errorMessage('Error de conexión');
    }
  }

  void _decodePolyline(String encodedPolyline) {
    try {
      List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(
        encodedPolyline,
      );

      setState(() {
        _route = decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      });

      if (_route.isNotEmpty) {
        double minLat = _route.first.latitude;
        double maxLat = _route.first.latitude;
        double minLng = _route.first.longitude;
        double maxLng = _route.first.longitude;

        for (var point in _route) {
          if (point.latitude < minLat) minLat = point.latitude;
          if (point.latitude > maxLat) maxLat = point.latitude;
          if (point.longitude < minLng) minLng = point.longitude;
          if (point.longitude > maxLng) maxLng = point.longitude;
        }

        LatLng center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

        _mapController.move(center, 13);
      }
    } catch (e) {
      errorMessage('Error al procesar la ruta');
    }
  }

  Future<bool> _checktheRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      errorMessage("Ubicación no disponible");
    }
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Gran Canaria MAP"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un destino...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        fetchCoordinates(value);
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_locationController.text.isNotEmpty) {
                      fetchCoordinates(_locationController.text);
                    } else {
                      errorMessage('Escribe un destino');
                    }
                  },
                  child: Text('Buscar'),
                ),
              ],
            ),
          ),

          if (isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(),
            ),

          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _currentLocation ??
                    LatLng(27.85218262745838, -15.438743613499692),
                initialZoom: 13,
                minZoom: 0,
                maxZoom: 100,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),

                if (_route.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _route,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),

                if (_destination != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: _destination!,
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),

                CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      child: Icon(Icons.location_pin, color: Colors.white),
                    ),
                    markerSize: Size(35, 35),
                    markerDirection: MarkerDirection.heading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _userCurrentLocation,
        backgroundColor: Colors.blue,
        child: Icon(Icons.my_location, size: 30, color: Colors.white),
      ),
    );
  }
}
