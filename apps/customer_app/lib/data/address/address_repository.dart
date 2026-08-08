import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:uuid/uuid.dart';
import 'package:customer_app/data/address/address_model.dart';

/// Persists the customer's saved delivery addresses on-device.
///
/// There is no backend endpoint for address book management yet, so this
/// stores addresses locally rather than pretending to sync them — checkout
/// reads from here instead of a hardcoded string, which is the actual bug
/// this repository exists to fix.
class AddressRepository {
  static const _storageKey = 'customer_addresses';
  static const _defaultIdKey = 'customer_default_address_id';

  final LocalStorageService _storage;
  AddressRepository(this._storage);

  Future<List<AddressModel>> list() async {
    final raw = await _storage.get<List<dynamic>>(_storageKey);
    if (raw == null) return const [];
    return raw.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AddressModel?> getDefault() async {
    final addresses = await list();
    if (addresses.isEmpty) return null;
    final defaultId = await _storage.get<String>(_defaultIdKey);
    return addresses.firstWhere((a) => a.id == defaultId, orElse: () => addresses.first);
  }

  Future<AddressModel> add({
    required String label,
    required String line1,
    required String city,
    required String postalCode,
  }) async {
    final addresses = await list();
    final address = AddressModel(
      id: const Uuid().v4(),
      label: label,
      line1: line1,
      city: city,
      postalCode: postalCode,
    );
    final updated = [...addresses, address];
    await _storage.save(_storageKey, updated.map((a) => a.toJson()).toList());
    if (addresses.isEmpty) {
      await _storage.save(_defaultIdKey, address.id);
    }
    return address;
  }

  Future<void> setDefault(String addressId) => _storage.save(_defaultIdKey, addressId);

  Future<void> delete(String addressId) async {
    final addresses = await list();
    final updated = addresses.where((a) => a.id != addressId).toList();
    await _storage.save(_storageKey, updated.map((a) => a.toJson()).toList());

    final defaultId = await _storage.get<String>(_defaultIdKey);
    if (defaultId == addressId) {
      if (updated.isEmpty) {
        await _storage.delete(_defaultIdKey);
      } else {
        await _storage.save(_defaultIdKey, updated.first.id);
      }
    }
  }
}
