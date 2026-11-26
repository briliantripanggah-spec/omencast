import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/open_meteo_service.dart';
import '../services/storage_service.dart';

class SearchViewModel extends ChangeNotifier {
  final OpenMeteoService _apiService;
  final StorageService _storageService;

  SearchViewModel(this._apiService, this._storageService) {
    loadFavorites();
  }

  List<LocationModel> _searchResults = [];
  List<LocationModel> _favorites = [];
  final Map<int, WeatherModel> _favoriteWeathers = {};
  bool _isSearching = false;
  bool _isLoadingFavoritesWeather = false;
  bool _hasSearched = false;
  String? _errorMessage;

  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get favorites => _favorites;
  Map<int, WeatherModel> get favoriteWeathers => _favoriteWeathers;
  bool get isSearching => _isSearching;
  bool get isLoadingFavoritesWeather => _isLoadingFavoritesWeather;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;

  void loadFavorites() {
    _favorites = _storageService.getFavorites();
    notifyListeners();
  }

  Future<void> fetchFavoritesWeather() async {
    loadFavorites();
    if (_favorites.isEmpty) return;

    _isLoadingFavoritesWeather = true;
    notifyListeners();

    await Future.wait(
      _favorites.map((loc) async {
        try {
          final weather = await _apiService.fetchWeather(
            loc.latitude,
            loc.longitude,
          );
          _favoriteWeathers[loc.id] = weather;
        } catch (_) {
          // Abaikan jika salah satu kota gagal dimuat agar kota lain tetap tampil
        }
      }),
    );

    _isLoadingFavoritesWeather = false;
    notifyListeners();
  }

  Future<void> searchCities(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _hasSearched = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _hasSearched = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchCities(query);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(LocationModel location) async {
    final wasFav = isFavorite(location.id);
    await _storageService.toggleFavorite(location);
    if (wasFav) {
      _favoriteWeathers.remove(location.id);
    }
    loadFavorites();
    if (!wasFav) {
      // Langsung ambil cuaca untuk kota yang baru ditambahkan
      try {
        _favoriteWeathers[location.id] = await _apiService.fetchWeather(
          location.latitude,
          location.longitude,
        );
        notifyListeners();
      } catch (_) {}
    }
  }

  bool isFavorite(int locationId) {
    return _storageService.isFavorite(locationId);
  }

  void clearSearch() {
    _searchResults = [];
    _hasSearched = false;
    _errorMessage = null;
    notifyListeners();
  }
}
