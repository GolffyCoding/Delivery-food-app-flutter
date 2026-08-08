import 'package:geolocator/geolocator.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_location/opendelivery_location.dart';

/// Service for device location access and geocoding.
class LocationService {
  Future<bool> get isLocationServiceEnabled async => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() => Geolocator.requestPermission();

  Future<LatLngEntity> getCurrentLocation() async {
    final serviceEnabled = await isLocationServiceEnabled;
    if (!serviceEnabled) {
      throw const LocalFailure(message: 'Location services are disabled');
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocalFailure(message: 'Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocalFailure(message: 'Location permission permanently denied. Please enable in settings.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
    );

    return LatLngEntity(latitude: position.latitude, longitude: position.longitude);
  }

  Stream<LatLngEntity> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).map((position) => LatLngEntity(latitude: position.latitude, longitude: position.longitude));
  }

  double calculateDistance(LatLngEntity from, LatLngEntity to) => from.distanceTo(to);
}
