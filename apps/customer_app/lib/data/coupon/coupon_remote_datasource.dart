import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

class CouponRemoteDatasource {
  final DioClient _dioClient;
  CouponRemoteDatasource(this._dioClient);

  Future<List<dynamic>> listActive() async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.coupons,
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> validate(String code, double subtotal) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.couponsValidate,
      data: {'code': code, 'subtotal': subtotal},
      decoder: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }
}
