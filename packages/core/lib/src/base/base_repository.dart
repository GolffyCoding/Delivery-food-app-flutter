import 'package:opendelivery_core/opendelivery_core.dart';

/// Base repository interface.
abstract class BaseRepository<T> {
  Future<Result<T, Failure>> getById(String id);
  Future<Result<List<T>, Failure>> getAll();
  Future<Result<T, Failure>> create(T entity);
  Future<Result<T, Failure>> update(T entity);
  Future<Result<void, Failure>> delete(String id);
}
