/// Domain usecase for resolving destination coordinates and building Google Maps URIs.
///
/// Handles coordinate lookup from multiple sources:
/// 1. Activity model coordinates (primary)
/// 2. Hardcoded destination coordinates map (fallback)
/// 3. Text search as last resort

class ResolveDestinationLocationUseCase {
  /// Comprehensive map of Kyoto destinations with their GPS coordinates
  static const Map<String, List<double>> _destinationCoordinates = {
    'golden pavilion': [35.0394, 135.7292],
    'golden pavillion': [35.0394, 135.7292],
    'fushimi inari shrine': [34.9671, 135.7727],
    'arashiyama bamboo grove': [35.0170, 135.6713],
    'ichiran ramen': [35.0037, 135.7681],
    'nishiki warai': [35.0050, 135.7640],
    'katsukura': [35.0087, 135.7688],
    'gion district': [35.0037, 135.7788],
    'bar k6': [35.0074, 135.7706],
    'kyoto granbell hotel': [34.9978, 135.7850],
    'hotel gracery kyoto': [34.9858, 135.7580],
    'nishiki market': [35.0050, 135.7640],
    'teramachi shopping street': [35.0087, 135.7688],
    'kyoto station building': [34.9855, 135.7584],
    'toho cinemas nijojo': [35.0142, 135.7481],
    'movix kyoto': [34.9855, 135.7584],
  };

  /// Resolves destination coordinates from multiple sources
  ///
  /// Priority:
  /// 1. Activity model coordinates (if available)
  /// 2. Hardcoded destination map lookup
  /// 3. null (fallback to text search)
  ///
  /// Parameters:
  /// - [destinationName]: Primary name identifier
  /// - [location]: Secondary location identifier
  /// - [activityLatitude]: Optional latitude from activity model
  /// - [activityLongitude]: Optional longitude from activity model
  ///
  /// Returns: [lat, lon] or null
  List<double>? resolveCoordinates({
    required String destinationName,
    required String location,
    double? activityLatitude,
    double? activityLongitude,
  }) {
    // Primary: Activity model coordinates
    if (activityLatitude != null && activityLongitude != null) {
      return [activityLatitude, activityLongitude];
    }

    // Secondary: Hardcoded destination map
    final nameKey = destinationName.toLowerCase().trim();
    final locationKey = location.toLowerCase().trim();

    return _destinationCoordinates[nameKey] ??
        _destinationCoordinates[locationKey];
  }

  /// Builds a Google Maps search URI
  ///
  /// Uses coordinates if available, otherwise builds a text search query.
  ///
  /// Parameters:
  /// - [destinationName]: Name to display in search
  /// - [destinationLocation]: Location to include in search
  /// - [coordinates]: Optional [lat, lon] to use for precise lookup
  ///
  /// Returns: Google Maps search URI or empty string if no data available
  String buildGoogleMapsUri({
    required String destinationName,
    required String destinationLocation,
    List<double>? coordinates,
  }) {
    final query = coordinates != null
        ? '${coordinates[0]},${coordinates[1]}'
        : [
            destinationName.trim(),
            destinationLocation.trim(),
          ].where((part) => part.isNotEmpty).join(', ');

    if (query.isEmpty) {
      return '';
    }

    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
  }
}
