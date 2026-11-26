class LocationModel {
  final int id;
  final String name;
  final String country;
  final String? admin1; // Provinsi/wilayah
  final double latitude;
  final double longitude;

  LocationModel({
    required this.id,
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Realm',
      country: json['country'] ?? '',
      admin1: json['admin1'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty) {
      return '$name, $admin1, $country';
    }
    return country.isNotEmpty ? '$name, $country' : name;
  }
}
