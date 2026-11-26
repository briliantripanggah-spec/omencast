import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectLocation(LocationModel location) {
    context.read<WeatherViewModel>().fetchWeatherForLocation(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('SEARCH REALMS'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1726), Color(0xFF110F1A), Color(0xFF0B0A0F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        context.read<SearchViewModel>().searchCities(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter city name (e.g. Purwokerto, Tokyo)...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () {
                            _controller.clear();
                            context.read<SearchViewModel>().clearSearch();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Consumer<SearchViewModel>(
                        builder: (context, vm, _) {
                          if (vm.isSearching) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.accentGold,
                              ),
                            );
                          }

                          if (vm.errorMessage != null) {
                            return Center(
                              child: Text(
                                vm.errorMessage!,
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          if (vm.hasSearched) {
                            if (vm.searchResults.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No realms found for that name.',
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: vm.searchResults.length,
                              itemBuilder: (context, index) {
                                final loc = vm.searchResults[index];
                                final isFav = vm.isFavorite(loc.id);
                                return _LocationTile(
                                  location: loc,
                                  isFavorite: isFav,
                                  onTap: () => _selectLocation(loc),
                                  onToggleFavorite: () =>
                                      vm.toggleFavorite(loc),
                                );
                              },
                            );
                          }

                          if (vm.favorites.isEmpty) {
                            return const Center(
                              child: Text(
                                'No saved realms yet.\nSearch a city and tap the star to save it.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 10, left: 4),
                                child: Text(
                                  'SAVED REALMS',
                                  style: TextStyle(
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: vm.favorites.length,
                                  itemBuilder: (context, index) {
                                    final loc = vm.favorites[index];
                                    return _LocationTile(
                                      location: loc,
                                      isFavorite: true,
                                      onTap: () => _selectLocation(loc),
                                      onToggleFavorite: () =>
                                          vm.toggleFavorite(loc),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _LocationTile({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(
          Icons.location_on_outlined,
          color: AppTheme.accentGold,
        ),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          location.displayName,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: isFavorite ? AppTheme.accentGold : AppTheme.textMuted,
          ),
          onPressed: onToggleFavorite,
        ),
      ),
    );
  }
}
