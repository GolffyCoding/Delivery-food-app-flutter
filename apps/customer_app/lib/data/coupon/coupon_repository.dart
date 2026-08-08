import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:customer_app/data/coupon/coupon_remote_datasource.dart';
import 'package:customer_app/domain/models/coupon_model.dart';

class CouponRepository {
  final CouponRemoteDatasource _datasource;
  CouponRepository(this._datasource);

  Future<Result<List<CouponModel>, Failure>> listActive() async {
    try {
      final json = await _datasource.listActive();
      return Result.success(json.map((e) => CouponModel.fromJson(e as Map<String, dynamic>)).toList());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<CouponPreview, Failure>> validate(String code, double subtotal) async {
    try {
      final json = await _datasource.validate(code, subtotal);
      return Result.success(CouponPreview.fromJson(json));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
