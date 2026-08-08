import 'dart:math' as math;
import 'package:equatable/equatable.dart';

class LatLngEntity extends Equatable {
  final double latitude;
  final double longitude;

  const LatLngEntity({required this.latitude, required this.longitude});

  double get latitudeRad => latitude * (math.pi / 180);
  double get longitudeRad => longitude * (math.pi / 180);

  /// Haversine distance in kilometers.
  double distanceTo(LatLngEntity other) {
    const earthRadius = 6371.0;
    final dLat = (other.latitude - latitude) * (math.pi / 180);
    final dLon = (other.longitude - longitude) * (math.pi / 180);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(latitudeRad) * math.cos(other.latitudeRad) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
