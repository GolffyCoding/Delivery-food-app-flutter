class AddressModel {
  final String id;
  final String label;
  final String line1;
  final String city;
  final String postalCode;
  final double? lat;
  final double? lng;

  const AddressModel({
    required this.id,
    required this.label,
    required this.line1,
    required this.city,
    required this.postalCode,
    this.lat,
    this.lng,
  });

  String get formatted => '$line1, $city $postalCode';

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'line1': line1,
        'city': city,
        'postalCode': postalCode,
        'lat': lat,
        'lng': lng,
      };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as String,
        label: json['label'] as String,
        line1: json['line1'] as String,
        city: json['city'] as String,
        postalCode: json['postalCode'] as String,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}
