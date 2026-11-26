import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/open_meteo_service.dart';
import '../services/storage_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final OpenMeteoService _apiService;
  final StorageService _storageService;

  WeatherViewModel(this._apiService, this._storageService);

  LocationModel _currentLocation = LocationModel(
    id: 1630328,
    name: 'Purwokerto',
    country: 'Indonesia',
    admin1: 'Central Java',
    latitude: -7.4243,
    longitude: 109.2391,
  );

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  LocationModel get currentLocation => _currentLocation;
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initWeather() async {
    final savedLocation = _storageService.getLastLocation();
    if (savedLocation != null) {
      _currentLocation = savedLocation;
    }
    await fetchWeatherForLocation(_currentLocation);
  }

  Future<void> fetchWeatherForLocation(LocationModel location) async {
    _currentLocation = location;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _storageService.saveLastLocation(location);
      _weather = await _apiService.fetchWeather(
        location.latitude,
        location.longitude,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    await fetchWeatherForLocation(_currentLocation);
  }
}
