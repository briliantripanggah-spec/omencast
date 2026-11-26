import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/weather_mapper.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/weather_background_animation.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().fetchFavoritesWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeLocationId = context
        .watch<WeatherViewModel>()
        .currentLocation
        .id;

    return Scaffold(
      backgroundColor: AppTheme.bgObsidian,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // Header: Back bulat, Judul, dan tombol + bulat
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'SAVED REALMS',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppTheme.textPrimary,
                                fontSize: 19,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ),
                      _CircleIconButton(
                        icon: Icons.add_rounded,
                        tooltip: 'Add Realm',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SearchScreen(),
                            ),
                          );
                          if (context.mounted) {
                            context
                                .read<SearchViewModel>()
                                .fetchFavoritesWeather();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Daftar Kartu Favorit
                Expanded(
                  child: Consumer<SearchViewModel>(
                    builder: (context, vm, _) {
                      if (vm.favorites.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star_border_rounded,
                                  size: 56,
                                  color: AppTheme.textMuted.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No saved realms yet.',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Tap the + button above to search and add cities.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppTheme.accentGold,
                        onRefresh: vm.fetchFavoritesWeather,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: vm.favorites.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final loc = vm.favorites[index];
                            final weather = vm.favoriteWeathers[loc.id];
                            final isCurrent = loc.id == activeLocationId;

                            return Dismissible(
                              key: ValueKey(loc.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (_) {
                                vm.toggleFavorite(loc);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${loc.name} removed from Saved Realms',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppTheme.surfaceDark,
                                  ),
                                );
                              },
                              child: _FavoriteCityCard(
                                location: loc,
                                weather: weather,
                                isCurrent: isCurrent,
                                onTap: () {
                                  context
                                      .read<WeatherViewModel>()
                                      .fetchWeatherForLocation(loc);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _FavoriteCityCard extends StatelessWidget {
  final LocationModel location;
  final WeatherModel? weather;
  final bool isCurrent;
  final VoidCallback onTap;

  const _FavoriteCityCard({
    required this.location,
    required this.weather,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather?.current;
    final today = (weather != null && weather!.daily.isNotEmpty)
        ? weather!.daily.first
        : null;
    final info = current != null
        ? WeatherMapper.fromCode(
            current.weatherCode,
            temperature: current.temperature,
          )
        : WeatherMapper.fromCode(-1);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 118,
          child: Stack(
            children: [
              // Gradient background sesuai cuaca kota
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: info.gradientColors,
                    ),
                  ),
                ),
              ),
              // Animasi cuaca mini di dalam kartu
              if (current != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.75,
                    child: WeatherBackgroundAnimation(
                      weatherCode: current.weatherCode,
                      temperature: current.temperature,
                    ),
                  ),
                ),
              // Lapisan gelap tipis agar teks selalu jelas terbaca
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.18)),
              ),
              // Konten teks kartu
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Kiri: Nama kota (+ pin jika aktif) & kondisi cuaca
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  location.name,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: AppTheme.accentGold,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            current != null ? info.label : 'Loading omen...',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Kanan: Suhu besar & min/max harian
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          current != null
                              ? '${current.temperature.round()}°'
                              : '--°',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          today != null
                              ? '${today.minTemp.round()}°/${today.maxTemp.round()}°'
                              : '--°/--°',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
