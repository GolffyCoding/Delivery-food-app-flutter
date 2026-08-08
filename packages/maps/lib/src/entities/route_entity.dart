import 'package:equatable/equatable.dart';
import 'package:opendelivery_location/opendelivery_location.dart';

class RouteEntity extends Equatable {
  final List<LatLngEntity> polylinePoints;
  final double totalDistance;
  final Duration estimatedDuration;
  final LatLngEntity origin;
  final LatLngEntity destination;

  const RouteEntity({
    required this.polylinePoints,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.origin,
    required this.destination,
  });

  String get distanceText =>
      totalDistance < 1 ? '${(totalDistance * 1000).round()}m' : '${totalDistance.toStringAsFixed(1)}km';

  String get durationText {
    final minutes = estimatedDuration.inMinutes;
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return remaining > 0 ? '${hours}h ${remaining}m' : '${hours}h';
  }

  @override
  List<Object?> get props => [origin, destination, totalDistance];
}
