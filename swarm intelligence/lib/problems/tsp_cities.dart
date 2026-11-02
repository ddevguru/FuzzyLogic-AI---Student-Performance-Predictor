import '../models/city.dart';

class TspCitiesData {
  static const List<City> defaultCities = [
    City(
      id: 0,
      name: 'Mumbai',
      x: 0.18,
      y: 0.58,
      latitude: 19.0760,
      longitude: 72.8777,
    ),
    City(
      id: 1,
      name: 'Pune',
      x: 0.32,
      y: 0.70,
      latitude: 18.5204,
      longitude: 73.8567,
    ),
    City(
      id: 2,
      name: 'Nashik',
      x: 0.35,
      y: 0.44,
      latitude: 19.9975,
      longitude: 73.7898,
    ),
    City(
      id: 3,
      name: 'Surat',
      x: 0.22,
      y: 0.30,
      latitude: 21.1702,
      longitude: 72.8311,
    ),
    City(
      id: 4,
      name: 'Goa',
      x: 0.30,
      y: 0.90,
      latitude: 15.2993,
      longitude: 74.1240,
    ),
    City(
      id: 5,
      name: 'Nagpur',
      x: 0.88,
      y: 0.38,
      latitude: 21.1458,
      longitude: 79.0882,
    ),
    City(
      id: 6,
      name: 'Ahmedabad',
      x: 0.15,
      y: 0.12,
      latitude: 23.0225,
      longitude: 72.5714,
    ),
    City(
      id: 7,
      name: 'Aurangabad',
      x: 0.56,
      y: 0.52,
      latitude: 19.8762,
      longitude: 75.3433,
    ),
  ];

  /// Precomputed distance matrix in kilometers
  static List<List<double>> computeDistanceMatrix(List<City> cities) {
    final n = cities.length;
    final matrix = List.generate(n, (_) => List.filled(n, 0.0));
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i == j) {
          matrix[i][j] = 0.0;
        } else {
          matrix[i][j] = cities[i].distanceToKm(cities[j]);
        }
      }
    }
    return matrix;
  }
}
