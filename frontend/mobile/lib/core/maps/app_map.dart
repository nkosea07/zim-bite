import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MapCoordinate {
  final double latitude;
  final double longitude;

  const MapCoordinate({required this.latitude, required this.longitude});
}

class MapPin {
  final String id;
  final MapCoordinate position;
  final Color color;

  const MapPin({
    required this.id,
    required this.position,
    this.color = Colors.red,
  });
}

/// Map widget backed by OpenStreetMap via flutter_map (pure Dart, no NDK).
class AppMap extends StatelessWidget {
  final MapCoordinate center;
  final List<MapPin> pins;
  final double zoom;
  final bool showMyLocation;

  const AppMap({
    super.key,
    required this.center,
    this.pins = const [],
    this.zoom = 14,
    this.showMyLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: latlng.LatLng(center.latitude, center.longitude),
        initialZoom: zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'co.zimbite.mobile',
        ),
        MarkerLayer(
          markers: pins
              .map(
                (pin) => Marker(
                  point: latlng.LatLng(
                    pin.position.latitude,
                    pin.position.longitude,
                  ),
                  width: 42,
                  height: 42,
                  child: Icon(Icons.location_on, color: pin.color, size: 36),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
