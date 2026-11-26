import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

class OpenMeteoService {
  static const String _weatherBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  Future<WeatherModel> fetchWeather(double latitude, double longitude) async {
    final uri = Uri.parse(_weatherBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
        'hourly': 'temperature_2m,precipitation_probability,weather_code',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset,uv_index_max',
        'timezone': 'auto',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherModel.fromJson(data);
    } else {
      throw Exception(
        'Failed to summon weather data (Code: ${response.statusCode})',
      );
    }
  }

  Future<List<LocationModel>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_geocodingBaseUrl).replace(
      queryParameters: {
        'name': query.trim(),
        'count': '10',
        'language': 'en',
        'format': 'json',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['results'] == null) return [];

      final List results = data['results'] as List;
      return results
          .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to search realms (Code: ${response.statusCode})');
    }
  }
}
