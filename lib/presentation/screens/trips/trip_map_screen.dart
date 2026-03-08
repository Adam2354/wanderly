import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../providers/trip_provider.dart';

class TripMapScreen extends ConsumerWidget {
  const TripMapScreen({super.key});

  static const _defaultCenter = LatLng(-6.2088, 106.8456);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(allTripMapPointsProvider);

    final markers = points
        .map(
          (point) => Marker(
            markerId: MarkerId(point.id),
            position: LatLng(point.latitude, point.longitude),
            infoWindow: InfoWindow(title: point.name, snippet: point.location),
          ),
        )
        .toSet();

    final initialCenter = points.isNotEmpty
        ? LatLng(points.first.latitude, points.first.longitude)
        : _defaultCenter;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialCenter,
              zoom: points.isNotEmpty ? 10 : 5,
            ),
            markers: markers,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: true,
          ),
          if (points.isEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Belum ada koordinat trip. Tambahkan Latitude dan Longitude saat membuat trip.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
