import 'package:opendelivery_location/opendelivery_location.dart';
import 'package:opendelivery_maps/opendelivery_maps.dart';

/// Straight-line route estimation.
/// NOTE: this intentionally has no `google_maps_flutter` / Directions API
/// dependency, since real turn-by-turn routing needs a Google Maps API key.
/// Swap [getRoute] for a Directions API call once that key exists.
class MapsService {
  const MapsService();

  RouteEntity getRoute({required LatLngEntity origin, required LatLngEntity destination}) {
    final totalDistance = origin.distanceTo(destination);
    final estimatedDuration = Duration(minutes: (totalDistance / 0.5).round().clamp(5, 120));

    return RouteEntity(
      polylinePoints: [origin, destination],
      totalDistance: totalDistance,
      estimatedDuration: estimatedDuration,
      origin: origin,
      destination: destination,
    );
  }
}
