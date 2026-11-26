import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/weather_mapper.dart';
import '../models/weather_model.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/weather_background_animation.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().initWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, vm, _) {
        final weather = vm.weather;
        final currentInfo = weather != null
            ? WeatherMapper.fromCode(
                weather.current.weatherCode,
                temperature: weather.current.temperature,
              )
            : WeatherMapper.fromCode(-1);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Saved Realms',
                      icon: const Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Search Realms',
                      icon: const Icon(Icons.search_rounded, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: currentInfo.gradientColors,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: WeatherBackgroundAnimation(
                    weatherCode: weather?.current.weatherCode ?? -1,
                    temperature: weather?.current.temperature,
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _buildBody(context, vm, currentInfo),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherViewModel vm,
    WeatherInfo currentInfo,
  ) {
    if (vm.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.accentGold),
            SizedBox(height: 16),
            Text(
              'Reading the skies...',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 56,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: vm.refreshWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final weather = vm.weather;
    if (weather == null) {
      return const Center(child: Text('No omen available.'));
    }

    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    return RefreshIndicator(
      color: AppTheme.accentGold,
      onRefresh: vm.refreshWeather,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          // 1. Hero Header (Kota, Suhu Besar, Kondisi & Min/Max)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(
                  vm.currentLocation.name,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontSize: 28, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  '${weather.current.temperature.round()}°',
                  style: Theme.of(context).textTheme.displayLarge
                      ?.copyWith(fontSize: 72, height: 1.05),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentInfo.label}  ${today != null ? '${today.minTemp.round()}° / ${today.maxTemp.round()}°' : ''}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '"${currentInfo.lore}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 2. Advisory / Quest Status Card
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      currentInfo.icon,
                      size: 18,
                      color: currentInfo.statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentInfo.questStatus,
                        style: TextStyle(
                          color: currentInfo.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _buildAdvisoryText(weather, today),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Next 24 Hours (Horizontal Scroll)
          if (weather.hourly.isNotEmpty) ...[
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardHeader(
                    icon: Icons.access_time_rounded,
                    title: 'Next 24 Hours',
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 108,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: weather.hourly.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 18),
                      itemBuilder: (context, index) {
                        final h = weather.hourly[index];
                        final hInfo = WeatherMapper.fromCode(h.weatherCode);
                        final dt = DateTime.tryParse(h.time);
                        final label = index == 0
                            ? 'Now'
                            : (dt != null
                                  ? DateFormat('HH:mm').format(dt)
                                  : '');

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: index == 0
                                    ? AppTheme.accentGold
                                    : AppTheme.textMuted,
                                fontSize: 12,
                                fontWeight: index == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Icon(hInfo.icon, color: hInfo.glowColor, size: 24),
                            Text(
                              '${h.precipitationProbability}%',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${h.temperature.round()}°',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 12),
          ],

          // 4. Next 7 Days (Dalam 1 Kartu Besar)
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardHeader(
                  icon: Icons.calendar_today_rounded,
                  title: 'Next 7 Days',
                ),
                const SizedBox(height: 12),
                ...weather.daily.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final day = entry.value;
                  final info = WeatherMapper.fromCode(day.weatherCode);
                  final dt = DateTime.tryParse(day.date);
                  final dateLabel = idx == 0
                      ? 'Today'
                      : (dt != null
                            ? DateFormat('MMM d').format(dt)
                            : day.date);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 68,
                          child: Text(
                            dateLabel,
                            style: TextStyle(
                              color: idx == 0
                                  ? AppTheme.accentGold
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Column(
                            children: [
                              Icon(info.icon, color: info.glowColor, size: 20),
                              Text(
                                '${day.precipitationProbabilityMax}%',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            info.label,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${day.minTemp.round()}° / ${day.maxTemp.round()}°',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 5. Bento Grid 2 Kolom (Precipitation, Wind, Feels Like, UV, Humidity, Sun)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.08,
            children: [
              _BentoMetricCard(
                icon: Icons.umbrella_rounded,
                title: 'Precipitation',
                value: '${weather.current.precipitation.toStringAsFixed(1)} mm',
                subValue: today != null
                    ? '${today.precipitationProbabilityMax}%'
                    : null,
                footer: weather.current.precipitation > 0
                    ? 'Active rainfall detected'
                    : 'Dry skies for now',
              ),
              _BentoMetricCard(
                icon: Icons.air_rounded,
                title: 'Wind',
                value: weather.current.windSpeed.toStringAsFixed(1),
                subValue: 'km/h',
                footer: weather.current.windSpeed > 20
                    ? 'Strong gusts blowing'
                    : 'Gentle breeze across realm',
              ),
              _BentoMetricCard(
                icon: Icons.thermostat_rounded,
                title: 'Feels Like',
                value: '${weather.current.apparentTemperature.round()}°C',
                footer:
                    weather.current.apparentTemperature >
                        weather.current.temperature
                    ? 'Feels warmer due to humidity'
                    : 'Feels close to actual temp',
              ),
              _BentoMetricCard(
                icon: Icons.wb_sunny_outlined,
                title: 'UV Index',
                value: today != null
                    ? today.uvIndexMax.toStringAsFixed(0)
                    : '-',
                subValue: _uvLabel(today?.uvIndexMax ?? 0),
                footer: (today?.uvIndexMax ?? 0) >= 6
                    ? 'Seek shade & protection'
                    : 'Safely enjoy the daylight',
              ),
              _BentoMetricCard(
                icon: Icons.water_drop_outlined,
                title: 'Humidity',
                value: '${weather.current.relativeHumidity}%',
                footer: weather.current.relativeHumidity >= 80
                    ? 'Extremely humid and muggy'
                    : 'Comfortable air moisture',
              ),
              _SunArcCard(
                sunrise: today?.sunrise ?? '',
                sunset: today?.sunset ?? '',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 6. Life Index / Adventurer's Index
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardHeader(
                  icon: Icons.shield_moon_outlined,
                  title: 'Adventurer\'s Index',
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: _buildLifeIndexItems(weather, today),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildAdvisoryText(WeatherModel weather, DailyForecast? today) {
    final rainProb = today?.precipitationProbabilityMax ?? 0;
    if (rainProb >= 70) {
      return 'Chance of rain today is $rainProb%. Prepare a cloak or umbrella before venturing out.';
    }
    if (weather.current.temperature >= 33) {
      return 'High temperatures detected (${weather.current.temperature.round()}°C). Stay hydrated and avoid prolonged sun exposure.';
    }
    if (weather.current.temperature <= 12) {
      return 'Chilly conditions (${weather.current.temperature.round()}°C). Equip warm layers for your journey.';
    }
    return 'Conditions are relatively stable with ${weather.current.relativeHumidity}% humidity. Good time to plan your outdoor activities.';
  }

  String _uvLabel(double uv) {
    if (uv >= 8) return 'Very High';
    if (uv >= 6) return 'High';
    if (uv >= 3) return 'Moderate';
    return 'Low';
  }

  List<Widget> _buildLifeIndexItems(WeatherModel w, DailyForecast? today) {
    final code = w.current.weatherCode;
    final temp = w.current.temperature;
    final wind = w.current.windSpeed;
    final hum = w.current.relativeHumidity;
    final rainProb = today?.precipitationProbabilityMax ?? 0;

    final isStorm = code == 95 || code == 96 || code == 99;
    final isRain = {51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82}
        .contains(code);
    final isSnow = {71, 73, 75, 77, 85, 86}.contains(code);
    final isFog = code == 45 || code == 48;
    final isClear = code == 0;

    // 1. Outdoor Training / Olahraga
    late final String trainingText;
    late final Color trainingColor;
    if (isStorm || temp <= 0 || temp >= 36) {
      trainingText = 'Avoid outdoor training, stay indoors';
      trainingColor = const Color(0xFFF87171); // Merah
    } else if (isRain || isSnow || wind >= 25) {
      trainingText = 'Indoor gym or tavern rest advised';
      trainingColor = const Color(0xFFFACC15); // Kuning
    } else if (temp >= 30 && hum >= 75) {
      trainingText = 'Hot & humid, light training only';
      trainingColor = const Color(0xFFFACC15);
    } else {
      trainingText = 'Great conditions for outdoor training';
      trainingColor = const Color(0xFF4ADE80); // Hijau
    }

    // 2. Exploration / Traveling
    late final String travelText;
    late final Color travelColor;
    if (isStorm || temp <= -10) {
      travelText = 'Hazardous roads, postpone travel';
      travelColor = const Color(0xFFF87171);
    } else if (isFog) {
      travelText = 'Low visibility, drive & walk carefully';
      travelColor = const Color(0xFFFACC15);
    } else if (isRain || isSnow || rainProb >= 70) {
      travelText = 'Slippery paths, bring waterproof gear';
      travelColor = const Color(0xFF38BDF8);
    } else {
      travelText = 'Ideal weather for traveling & quests';
      travelColor = const Color(0xFF4ADE80);
    }

    // 3. Campfire / Stargazing / Hangout
    late final IconData leisureIcon;
    late final String leisureText;
    late final Color leisureColor;
    if (isStorm || isRain || isSnow || temp <= 5) {
      leisureIcon = Icons.local_cafe_rounded;
      leisureText = 'Best time for warm drinks indoors';
      leisureColor = const Color(0xFF93C5FD);
    } else if (isClear && wind < 20) {
      leisureIcon = Icons.nights_stay_rounded;
      leisureText = 'Perfect for stargazing & campfires';
      leisureColor = const Color(0xFFD4AF37);
    } else {
      leisureIcon = Icons.park_rounded;
      leisureText = 'Nice weather for a casual walk';
      leisureColor = const Color(0xFF4ADE80);
    }

    // 4. Gear / Attire
    late final IconData gearIcon;
    late final String gearText;
    late final Color gearColor;
    if (temp <= 5 || isSnow) {
      gearIcon = Icons.ac_unit_rounded;
      gearText = 'Heavy thermal armor & gloves required';
      gearColor = const Color(0xFF7DD3FC);
    } else if (isRain || isStorm || rainProb >= 60) {
      gearIcon = Icons.umbrella_rounded;
      gearText = 'Carry a rain cloak or umbrella';
      gearColor = const Color(0xFF38BDF8);
    } else if (temp <= 18) {
      gearIcon = Icons.checkroom_rounded;
      gearText = 'Wear a warm jacket or layered cloak';
      gearColor = AppTheme.accentGold;
    } else {
      gearIcon = Icons.wb_sunny_outlined;
      gearText = 'Light, breathable attire advised';
      gearColor = AppTheme.accentGold;
    }

    return [
      _LifeIndexItem(
        icon: Icons.directions_run_rounded,
        iconColor: trainingColor,
        text: trainingText,
      ),
      _LifeIndexItem(
        icon: Icons.explore_rounded,
        iconColor: travelColor,
        text: travelText,
      ),
      _LifeIndexItem(
        icon: leisureIcon,
        iconColor: leisureColor,
        text: leisureText,
      ),
      _LifeIndexItem(
        icon: gearIcon,
        iconColor: gearColor,
        text: gearText,
      ),
    ];
  }
}

// ==================== REUSABLE BENTO WIDGETS ====================

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.accentGold),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BentoMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subValue;
  final String footer;

  const _BentoMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subValue,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CardHeader(icon: icon, title: title),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(width: 6),
                Text(
                  subValue!,
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          Text(
            footer,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11.5,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SunArcCard extends StatelessWidget {
  final String sunrise;
  final String sunset;

  const _SunArcCard({required this.sunrise, required this.sunset});

  @override
  Widget build(BuildContext context) {
    final sr = DateTime.tryParse(sunrise);
    final ss = DateTime.tryParse(sunset);
    final srText = sr != null ? DateFormat('HH:mm').format(sr) : '--:--';
    final ssText = ss != null ? DateFormat('HH:mm').format(ss) : '--:--';

    double sunProgress = 0.5;
    if (sr != null && ss != null) {
      final now = DateTime.now();
      final total = ss.difference(sr).inMinutes;
      final elapsed = now.difference(sr).inMinutes;
      if (total > 0) {
        sunProgress = (elapsed / total).clamp(0.0, 1.0);
      }
    }

    return _GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _CardHeader(icon: Icons.wb_sunny_rounded, title: 'Sun'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CustomPaint(
                size: Size.infinite,
                painter: _SunArcPainter(progress: sunProgress),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                srText,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ssText,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;

  _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.85;
    final radius = min(size.width * 0.42, size.height * 0.72);
    final center = Offset(size.width / 2, horizonY);

    // Garis horizon
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      Paint()
        ..color = AppTheme.textMuted.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );

    // Lengkung lintasan matahari
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      arcRect,
      pi,
      pi,
      false,
      Paint()
        ..color = AppTheme.textMuted.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Lengkung yang sudah dilalui
    canvas.drawArc(
      arcRect,
      pi,
      pi * progress,
      false,
      Paint()
        ..color = AppTheme.accentGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // Titik matahari
    final angle = pi + (pi * progress);
    final sunPos = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    canvas.drawCircle(
      sunPos,
      7,
      Paint()..color = AppTheme.accentGold.withValues(alpha: 0.3),
    );
    canvas.drawCircle(sunPos, 4.5, Paint()..color = const Color(0xFFFDE047));
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LifeIndexItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _LifeIndexItem({
    required this.icon,
    this.iconColor = AppTheme.accentGold,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 26),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
