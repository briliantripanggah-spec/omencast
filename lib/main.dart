import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/open_meteo_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final apiService = OpenMeteoService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(apiService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(apiService, storageService),
        ),
      ],
      child: const OmenCastApp(),
    ),
  );
}

class OmenCastApp extends StatelessWidget {
  const OmenCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmenCast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
