import 'package:equatable/equatable.dart';
import 'package:opendelivery_location/opendelivery_location.dart';

class AddressEntity extends Equatable {
  final String id;
  final String fullAddress;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final LatLngEntity coordinates;
  final String? label;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.fullAddress,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.coordinates,
    this.label,
    this.isDefault = false,
  });

  String get shortAddress => '$street, $city';

  @override
  List<Object?> get props => [id, fullAddress, coordinates];
}
