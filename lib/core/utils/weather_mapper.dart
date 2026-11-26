import 'package:flutter/material.dart';

class WeatherInfo {
  final String label;
  final String lore;
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;
  final String questStatus;
  final Color statusColor;

  const WeatherInfo({
    required this.label,
    required this.lore,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    required this.questStatus,
    required this.statusColor,
  });

  WeatherInfo copyWith({String? questStatus, Color? statusColor}) {
    return WeatherInfo(
      label: label,
      lore: lore,
      icon: icon,
      gradientColors: gradientColors,
      glowColor: glowColor,
      questStatus: questStatus ?? this.questStatus,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

class WeatherMapper {
  static WeatherInfo fromCode(int code, {double? temperature}) {
    final baseInfo = _baseFromCode(code);
    if (temperature == null) return baseInfo;

    // 1. Badai petir tetap prioritas bahaya tertinggi
    if (code == 95 || code == 96 || code == 99) {
      return baseInfo;
    }

    // 2. Suhu ekstrem meng-override status cuaca biasa
    if (temperature >= 35) {
      return baseInfo.copyWith(
        questStatus: 'HAZARD: SCORCHING HEAT',
        statusColor: const Color(0xFFFB923C),
      );
    }
    if (temperature <= 5) {
      return baseInfo.copyWith(
        questStatus: 'HAZARD: FREEZING COLD',
        statusColor: const Color(0xFF7DD3FC),
      );
    }

    // 3. Hujan & salju tetap butuh peringatan perlengkapan
    const rainAndSnowCodes = {
      61,
      63,
      65,
      66,
      67,
      71,
      73,
      75,
      77,
      80,
      81,
      82,
      85,
      86,
    };
    if (rainAndSnowCodes.contains(code)) {
      return baseInfo;
    }

    // 4. Suhu cukup panas atau dingin saat cuaca cerah/berawan/gerimis
    if (temperature >= 31) {
      return baseInfo.copyWith(
        questStatus: 'ADVISORY: HIGH HEAT',
        statusColor: const Color(0xFFFACC15),
      );
    }
    if (temperature <= 15) {
      return baseInfo.copyWith(
        questStatus: 'ADVISORY: CHILLY WINDS',
        statusColor: const Color(0xFF93C5FD),
      );
    }

    return baseInfo;
  }

  static WeatherInfo _baseFromCode(int code) {
    switch (code) {
      case 0:
        return const WeatherInfo(
          label: 'Clear Sky',
          lore: 'Radiant skies favor your quest.',
          icon: Icons.wb_sunny_rounded,
          gradientColors: [
            Color(0xFF1F1A2E),
            Color(0xFF14111D),
            Color(0xFF0B0A0F),
          ],
          glowColor: Color(0xFFD4AF37),
          questStatus: 'QUEST STATUS: FAVORABLE',
          statusColor: Color(0xFF4ADE80),
        );
      case 1:
      case 2:
      case 3:
        return const WeatherInfo(
          label: 'Partly Cloudy',
          lore: 'Veiled clouds drift across the realm.',
          icon: Icons.cloud_queue_rounded,
          gradientColors: [
            Color(0xFF1C1D2E),
            Color(0xFF13131F),
            Color(0xFF0B0A0F),
          ],
          glowColor: Color(0xFFA78BFA),
          questStatus: 'QUEST STATUS: STEADY',
          statusColor: Color(0xFFC084FC),
        );
      case 45:
      case 48:
        return const WeatherInfo(
          label: 'Foggy',
          lore: 'A thick shroud of mist conceals the path.',
          icon: Icons.foggy,
          gradientColors: [
            Color(0xFF21242B),
            Color(0xFF14161B),
            Color(0xFF0B0A0F),
          ],
          glowColor: Color(0xFF94A3B8),
          questStatus: 'CAUTION: LOW VISIBILITY',
          statusColor: Color(0xFFFACC15),
        );
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return const WeatherInfo(
          label: 'Drizzle',
          lore: 'Light droplets whisper from the dark.',
          icon: Icons.grain_rounded,
          gradientColors: [
            Color(0xFF132238),
            Color(0xFF0F1726),
            Color(0xFF0B0A0F),
          ],
          glowColor: Color(0xFF60A5FA),
          questStatus: 'ADVISORY: LIGHT CLOAK',
          statusColor: Color(0xFF60A5FA),
        );
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return const WeatherInfo(
          label: 'Rain',
          lore: 'The heavens weep upon the earth.',
          icon: Icons.water_drop_rounded,
          gradientColors: [
            Color(0xFF0F203A),
            Color(0xFF0D1524),
            Color(0xFF090A10),
          ],
          glowColor: Color(0xFF38BDF8),
          questStatus: 'HAZARD: BRING CLOAK',
          statusColor: Color(0xFF38BDF8),
        );
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return const WeatherInfo(
          label: 'Snowfall',
          lore: 'Frostbite descends from the frozen north.',
          icon: Icons.ac_unit_rounded,
          gradientColors: [
            Color(0xFF18263A),
            Color(0xFF111827),
            Color(0xFF0A0C12),
          ],
          glowColor: Color(0xFFBAE6FD),
          questStatus: 'HAZARD: FREEZING COLD',
          statusColor: Color(0xFF7DD3FC),
        );
      case 95:
      case 96:
      case 99:
        return const WeatherInfo(
          label: 'Thunderstorm',
          lore: 'Wrath of the tempest! Seek shelter.',
          icon: Icons.thunderstorm_rounded,
          gradientColors: [
            Color(0xFF2B1330),
            Color(0xFF170D21),
            Color(0xFF09080D),
          ],
          glowColor: Color(0xFFF87171),
          questStatus: 'DANGER: SEEK SHELTER',
          statusColor: Color(0xFFF87171),
        );
      default:
        return const WeatherInfo(
          label: 'Unknown',
          lore: 'The omens are unclear.',
          icon: Icons.help_outline_rounded,
          gradientColors: [
            Color(0xFF1A1726),
            Color(0xFF110F1A),
            Color(0xFF0B0A0F),
          ],
          glowColor: Color(0xFFD4AF37),
          questStatus: 'QUEST STATUS: UNKNOWN',
          statusColor: Color(0xFFA09CB0),
        );
    }
  }
}
