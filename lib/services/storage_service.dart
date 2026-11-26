import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/location_model.dart';

class StorageService {
  static const String _favoritesBoxName = 'favorites_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _lastLocationKey = 'last_location';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_favoritesBoxName);
    await Hive.openBox<String>(_settingsBoxName);
  }

  Box<String> get _favoritesBox => Hive.box<String>(_favoritesBoxName);
  Box<String> get _settingsBox => Hive.box<String>(_settingsBoxName);

  // Ambil semua lokasi favorit
  List<LocationModel> getFavorites() {
    return _favoritesBox.values.map((jsonStr) {
      return LocationModel.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
    }).toList();
  }

  // Tambah atau hapus lokasi favorit
  Future<void> toggleFavorite(LocationModel location) async {
    final key = location.id.toString();
    if (_favoritesBox.containsKey(key)) {
      await _favoritesBox.delete(key);
    } else {
      await _favoritesBox.put(key, jsonEncode(location.toJson()));
    }
  }

  bool isFavorite(int locationId) {
    return _favoritesBox.containsKey(locationId.toString());
  }

  // Simpan lokasi terakhir yang dilihat
  Future<void> saveLastLocation(LocationModel location) async {
    await _settingsBox.put(_lastLocationKey, jsonEncode(location.toJson()));
  }

  // Muat lokasi terakhir yang dilihat
  LocationModel? getLastLocation() {
    final jsonStr = _settingsBox.get(_lastLocationKey);
    if (jsonStr == null) return null;
    return LocationModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }
}
