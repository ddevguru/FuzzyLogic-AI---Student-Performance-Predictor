import 'dart:math';

class City {
  final int id;
  final String name;
  final double x; // Normalized coordinate in [0, 1] for canvas rendering
  final double y; // Normalized coordinate in [0, 1] for canvas rendering
  final double latitude;
  final double longitude;

  const City({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.latitude,
    required this.longitude,
  });

  /// Compute Euclidean distance on canvas plane
  double distanceToCanvas(City other, double width, double height) {
    final dx = (x - other.x) * width;
    final dy = (y - other.y) * height;
    return sqrt(dx * dx + dy * dy);
  }

  /// Compute geographical distance in kilometers using the Haversine formula
  double distanceToKm(City other) {
    const double r = 6371.0; // Earth radius in km
    final dLat = (other.latitude - latitude) * pi / 180.0;
    final dLon = (other.longitude - longitude) * pi / 180.0;
    final lat1 = latitude * pi / 180.0;
    final lat2 = other.latitude * pi / 180.0;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }
}
