import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/activity_model.dart';
import '../../domain/trips/usecases/resolve_destination_location_usecase.dart';

// =============================================================================
// USECASE PROVIDERS
// =============================================================================

/// Exposes the destination location resolution usecase
final resolveDestinationLocationProvider = Provider(
  (_) => ResolveDestinationLocationUseCase(),
);

// =============================================================================
// DESTINATION RESOLUTION PROVIDERS
// =============================================================================

/// Resolved destination coordinates for a given activity
///
/// Priority:
/// 1. Activity model coordinates
/// 2. Hardcoded destination map
/// 3. null (fallback to text search)
///
/// Family parameters:
/// - [destinationName]: Activity or destination name
/// - [location]: Location string
/// - [activity]: Optional ActivityModel for coordinate extraction
final destinationCoordinatesProvider =
    FutureProvider.family<
      List<double>?,
      ({String destinationName, String location, ActivityModel? activity})
    >((ref, params) async {
      final usecase = ref.watch(resolveDestinationLocationProvider);
      return usecase.resolveCoordinates(
        destinationName: params.destinationName,
        location: params.location,
        activityLatitude: params.activity?.latitude,
        activityLongitude: params.activity?.longitude,
      );
    });

// =============================================================================
// GOOGLE MAPS URI PROVIDERS
// =============================================================================

/// Google Maps search URI for opening location in maps application
///
/// Family parameters:
/// - [destinationName]: Activity or destination name
/// - [location]: Location string
/// - [activity]: Optional ActivityModel for coordinate extraction
final googleMapsUriProvider =
    FutureProvider.family<
      String,
      ({String destinationName, String location, ActivityModel? activity})
    >((ref, params) async {
      final usecase = ref.watch(resolveDestinationLocationProvider);
      final coordinates = usecase.resolveCoordinates(
        destinationName: params.destinationName,
        location: params.location,
        activityLatitude: params.activity?.latitude,
        activityLongitude: params.activity?.longitude,
      );

      return usecase.buildGoogleMapsUri(
        destinationName: params.destinationName,
        destinationLocation: params.location,
        coordinates: coordinates,
      );
    });
