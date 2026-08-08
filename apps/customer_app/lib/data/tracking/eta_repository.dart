import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

class EtaResult {
  final int estimatedMinutes;
  final double distanceKm;
  const EtaResult({required this.estimatedMinutes, required this.distanceKm});

  factory EtaResult.fromJson(Map<String, dynamic> json) => EtaResult(
        estimatedMinutes: (json['estimated_min'] as num?)?.toInt() ?? 0,
        distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      );
}

class EtaRepository {
  final DioClient _dioClient;
  EtaRepository(this._dioClient);

  Future<Result<EtaResult, Failure>> calculate({
    required double driverLat,
    required double driverLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        ApiConstants.trackingEta,
        data: {'driver_lat': driverLat, 'driver_lng': driverLng, 'dest_lat': destLat, 'dest_lng': destLng},
        decoder: (json) => json as Map<String, dynamic>,
      );
      return Result.success(EtaResult.fromJson(response.data ?? const {}));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
