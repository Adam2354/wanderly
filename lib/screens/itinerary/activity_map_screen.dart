import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/activity_model.dart';

class ActivityMapScreen extends StatelessWidget {
  const ActivityMapScreen({super.key, required this.activities});

  final List<ActivityModel> activities;

  static const _defaultCenter = LatLng(-6.2088, 106.8456);

  static const Map<String, LatLng> _locationCoordinates = {
    'kyoto, japan': LatLng(35.0116, 135.7681),
    'kyoto station': LatLng(34.9855, 135.7584),
    'nishiki market': LatLng(35.0050, 135.7640),
    'sanjo teramachi': LatLng(35.0087, 135.7688),
    'gion, kyoto': LatLng(35.0037, 135.7788),
    'pontocho alley': LatLng(35.0074, 135.7706),
    'higashiyama ward': LatLng(34.9978, 135.7850),
    'kyoto station area': LatLng(34.9858, 135.7580),
    'nakagyo ward': LatLng(35.0100, 135.7510),
    'downtown kyoto': LatLng(35.0056, 135.7681),
    'nijo castle area': LatLng(35.0142, 135.7481),
  };

  LatLng? _resolveCoordinates(ActivityModel activity) {
    if (activity.latitude != null && activity.longitude != null) {
      return LatLng(activity.latitude!, activity.longitude!);
    }

    return _locationCoordinates[activity.location.toLowerCase().trim()];
  }

  @override
  Widget build(BuildContext context) {
    final mapActivities = activities.where((activity) {
      return _resolveCoordinates(activity) != null;
    }).toList();

    final markers = mapActivities.map((activity) {
      final coordinates = _resolveCoordinates(activity)!;
      return Marker(
        markerId: MarkerId(
          activity.id ?? '${activity.name}_${activity.location}',
        ),
        position: coordinates,
        infoWindow: InfoWindow(
          title: activity.name,
          snippet: '${activity.category} • ${activity.location}',
        ),
      );
    }).toSet();

    final initialCenter = mapActivities.isNotEmpty
        ? _resolveCoordinates(mapActivities.first)!
        : _defaultCenter;

    return Scaffold(
      appBar: AppBar(title: const Text('Peta Wisata')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialCenter,
              zoom: mapActivities.isNotEmpty ? 12 : 5,
            ),
            markers: markers,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: true,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                mapActivities.isNotEmpty
                    ? '${mapActivities.length} marker dari daftar wisata saat ini'
                    : 'Daftar wisata ini belum punya koordinat lokasi',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
