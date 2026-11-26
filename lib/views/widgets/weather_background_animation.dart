import 'dart:math';

import 'package:flutter/material.dart';

enum _BiomeType {
  desert,
  iceMountains,
  rainforest,
  stormCitadel,
  mistyValley,
  fantasyHighlands,
}

class WeatherBackgroundAnimation extends StatefulWidget {
  final int weatherCode;
  final double? temperature;

  const WeatherBackgroundAnimation({
    super.key,
    required this.weatherCode,
    this.temperature,
  });

  @override
  State<WeatherBackgroundAnimation> createState() =>
      _WeatherBackgroundAnimationState();
}

class _WeatherBackgroundAnimationState extends State<WeatherBackgroundAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _weatherParticles;
  late final List<_Particle> _tempParticles;

  @override
  void initState() {
    super.initState();
    final rng = Random(42);
    _weatherParticles = List.generate(45, (_) => _Particle.random(rng));
    _tempParticles = List.generate(22, (_) => _Particle.random(rng));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _WeatherBackdropPainter(
              progress: _controller.value,
              weatherCode: widget.weatherCode,
              temperature: widget.temperature,
              weatherParticles: _weatherParticles,
              tempParticles: _tempParticles,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double drift;
  final double phase;

  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.drift,
    required this.phase,
  });

  factory _Particle.random(Random rng) {
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      speed: 0.4 + rng.nextDouble() * 1.2,
      size: 1.5 + rng.nextDouble() * 3.0,
      drift: (rng.nextDouble() - 0.5) * 0.15,
      phase: rng.nextDouble() * pi * 2,
    );
  }
}

class _WeatherBackdropPainter extends CustomPainter {
  final double progress;
  final int weatherCode;
  final double? temperature;
  final List<_Particle> weatherParticles;
  final List<_Particle> tempParticles;

  _WeatherBackdropPainter({
    required this.progress,
    required this.weatherCode,
    required this.temperature,
    required this.weatherParticles,
    required this.tempParticles,
  });

  _BiomeType _resolveBiome() {
    if (weatherCode == 95 || weatherCode == 96 || weatherCode == 99) {
      return _BiomeType.stormCitadel;
    }
    if ({71, 73, 75, 77, 85, 86}.contains(weatherCode) ||
        (temperature != null && temperature! <= 5)) {
      return _BiomeType.iceMountains;
    }
    if ({
      51,
      53,
      55,
      56,
      57,
      61,
      63,
      65,
      66,
      67,
      80,
      81,
      82,
    }.contains(weatherCode)) {
      return _BiomeType.rainforest;
    }
    if (weatherCode == 45 || weatherCode == 48) {
      return _BiomeType.mistyValley;
    }
    if (temperature != null && temperature! >= 31) {
      return _BiomeType.desert;
    }
    return _BiomeType.fantasyHighlands;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final biome = _resolveBiome();

    // 1. Layer Pemandangan (Scenery)
    switch (biome) {
      case _BiomeType.desert:
        _paintDesertScenery(canvas, size);
        break;
      case _BiomeType.iceMountains:
        _paintIceMountainsScenery(canvas, size);
        break;
      case _BiomeType.rainforest:
        _paintRainforestScenery(canvas, size);
        break;
      case _BiomeType.stormCitadel:
        _paintStormCitadelScenery(canvas, size);
        break;
      case _BiomeType.mistyValley:
        _paintMistyValleyScenery(canvas, size);
        break;
      case _BiomeType.fantasyHighlands:
        _paintFantasyHighlandsScenery(canvas, size);
        break;
    }

    // 2. Layer Aura & Partikel Suhu
    if (temperature != null) {
      _paintTemperatureLayer(canvas, size, temperature!);
    }

    // 3. Layer Animasi Cuaca
    if (weatherCode == 95 || weatherCode == 96 || weatherCode == 99) {
      _paintRain(canvas, size, heavy: true);
      _paintLightning(canvas, size);
    } else if ({61, 63, 65, 66, 67, 80, 81, 82}.contains(weatherCode)) {
      _paintRain(canvas, size, heavy: true);
    } else if ({51, 53, 55, 56, 57}.contains(weatherCode)) {
      _paintRain(canvas, size, heavy: false);
    } else if ({71, 73, 75, 77, 85, 86}.contains(weatherCode)) {
      _paintSnow(canvas, size);
    } else if (weatherCode == 45 || weatherCode == 48) {
      _paintMist(canvas, size, dense: true);
    } else if ({1, 2, 3}.contains(weatherCode)) {
      _paintMist(canvas, size, dense: false);
      _paintArcaneMotes(canvas, size, opacityScale: 0.5);
    } else {
      _paintArcaneMotes(canvas, size, opacityScale: 1.0);
    }
  }

  // ==================== SCENERY BIOMES ====================

  void _paintDesertScenery(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Matahari raksasa membara di cakrawala
    final sunCenter = Offset(w * 0.72, h * 0.56);
    final sunGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFB923C).withValues(alpha: 0.45),
          const Color(0xFFEA580C).withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.45));
    canvas.drawCircle(sunCenter, w * 0.45, sunGlow);
    canvas.drawCircle(
      sunCenter,
      w * 0.14,
      Paint()..color = const Color(0xFFFDBA74).withValues(alpha: 0.25),
    );

    // Bukit pasir belakang
    final duneBack = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.28, h * 0.62, w * 0.55, h * 0.71)
      ..quadraticBezierTo(w * 0.82, h * 0.79, w, h * 0.67)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      duneBack,
      Paint()..color = const Color(0xFF3B1D14).withValues(alpha: 0.65),
    );

    // Bukit pasir tengah
    final duneMid = Path()
      ..moveTo(0, h * 0.80)
      ..quadraticBezierTo(w * 0.35, h * 0.71, w * 0.68, h * 0.82)
      ..quadraticBezierTo(w * 0.88, h * 0.88, w, h * 0.78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      duneMid,
      Paint()..color = const Color(0xFF26120D).withValues(alpha: 0.85),
    );

    // Bukit pasir depan
    final duneFront = Path()
      ..moveTo(0, h * 0.89)
      ..quadraticBezierTo(w * 0.45, h * 0.83, w, h * 0.91)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(duneFront, Paint()..color = const Color(0xFF140907));
  }

  void _paintIceMountainsScenery(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bulan dingin pucat
    final moonCenter = Offset(w * 0.24, h * 0.22);
    final moonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFBAE6FD).withValues(alpha: 0.28),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: w * 0.32));
    canvas.drawCircle(moonCenter, w * 0.32, moonGlow);
    canvas.drawCircle(
      moonCenter,
      24,
      Paint()..color = const Color(0xFFE0F2FE).withValues(alpha: 0.35),
    );

    // Pegunungan es belakang
    final peakBack = Path()
      ..moveTo(0, h * 0.78)
      ..lineTo(w * 0.18, h * 0.58)
      ..lineTo(w * 0.36, h * 0.72)
      ..lineTo(w * 0.56, h * 0.53)
      ..lineTo(w * 0.76, h * 0.69)
      ..lineTo(w * 0.92, h * 0.57)
      ..lineTo(w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      peakBack,
      Paint()..color = const Color(0xFF1E3A5F).withValues(alpha: 0.55),
    );

    // Highlight puncak es (salju)
    final snowCap = Path()
      ..moveTo(w * 0.56, h * 0.53)
      ..lineTo(w * 0.50, h * 0.60)
      ..lineTo(w * 0.54, h * 0.585)
      ..lineTo(w * 0.57, h * 0.61)
      ..lineTo(w * 0.62, h * 0.59)
      ..close();
    canvas.drawPath(
      snowCap,
      Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.25),
    );

    // Pegunungan es depan
    final peakFront = Path()
      ..moveTo(0, h * 0.85)
      ..lineTo(w * 0.26, h * 0.69)
      ..lineTo(w * 0.48, h * 0.82)
      ..lineTo(w * 0.74, h * 0.67)
      ..lineTo(w, h * 0.83)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      peakFront,
      Paint()..color = const Color(0xFF0C1829).withValues(alpha: 0.92),
    );
  }

  void _paintRainforestScenery(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bukit hutan belakang
    final hillBack = Path()
      ..moveTo(0, h * 0.74)
      ..quadraticBezierTo(w * 0.3, h * 0.66, w * 0.6, h * 0.73)
      ..quadraticBezierTo(w * 0.85, h * 0.78, w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      hillBack,
      Paint()..color = const Color(0xFF0E2429).withValues(alpha: 0.65),
    );

    // Siluet deretan pohon hutan hujan (lapisan tengah)
    _drawPineTreeLine(
      canvas,
      size,
      baseY: h * 0.86,
      color: const Color(0xFF0A1D22).withValues(alpha: 0.85),
      treeCount: 11,
      minHeight: 42,
      maxHeight: 82,
      seedOffset: 0,
    );

    // Siluet deretan pohon hutan hujan (lapisan depan lebih gelap)
    _drawPineTreeLine(
      canvas,
      size,
      baseY: h * 0.95,
      color: const Color(0xFF061114),
      treeCount: 9,
      minHeight: 55,
      maxHeight: 105,
      seedOffset: 17,
    );
  }

  void _drawPineTreeLine(
    Canvas canvas,
    Size size, {
    required double baseY,
    required Color color,
    required int treeCount,
    required double minHeight,
    required double maxHeight,
    required int seedOffset,
  }) {
    final paint = Paint()..color = color;
    final step = size.width / (treeCount - 1);

    // Dasar tanah
    canvas.drawRect(Rect.fromLTRB(0, baseY, size.width, size.height), paint);

    for (int i = 0; i < treeCount; i++) {
      final cx = i * step + sin(i * 1.9 + seedOffset) * (step * 0.25);
      final heightFactor = 0.5 + 0.5 * sin(i * 2.7 + seedOffset);
      final treeH = minHeight + (maxHeight - minHeight) * heightFactor;
      final halfW = treeH * 0.32;

      final treePath = Path()
        ..moveTo(cx, baseY - treeH)
        ..lineTo(cx - halfW * 0.65, baseY - treeH * 0.55)
        ..lineTo(cx - halfW * 0.35, baseY - treeH * 0.55)
        ..lineTo(cx - halfW * 0.85, baseY - treeH * 0.22)
        ..lineTo(cx - halfW * 0.50, baseY - treeH * 0.22)
        ..lineTo(cx - halfW, baseY + 6)
        ..lineTo(cx + halfW, baseY + 6)
        ..lineTo(cx + halfW * 0.50, baseY - treeH * 0.22)
        ..lineTo(cx + halfW * 0.85, baseY - treeH * 0.22)
        ..lineTo(cx + halfW * 0.35, baseY - treeH * 0.55)
        ..lineTo(cx + halfW * 0.65, baseY - treeH * 0.55)
        ..close();

      canvas.drawPath(treePath, paint);
    }
  }

  void _paintStormCitadelScenery(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tebing gelap tajam
    final crags = Path()
      ..moveTo(0, h * 0.82)
      ..lineTo(w * 0.22, h * 0.67)
      ..lineTo(w * 0.42, h * 0.77)
      ..lineTo(w * 0.68, h * 0.62)
      ..lineTo(w * 0.85, h * 0.74)
      ..lineTo(w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      crags,
      Paint()..color = const Color(0xFF140B1F).withValues(alpha: 0.9),
    );

    // Siluet menara kastil gelap di puncak kanan
    final towerPaint = Paint()..color = const Color(0xFF0B0612);
    final tx = w * 0.68;
    final ty = h * 0.62;
    canvas.drawRect(Rect.fromLTWH(tx - 10, ty - 42, 20, 48), towerPaint);
    final spire = Path()
      ..moveTo(tx - 13, ty - 42)
      ..lineTo(tx, ty - 68)
      ..lineTo(tx + 13, ty - 42)
      ..close();
    canvas.drawPath(spire, towerPaint);
  }

  void _paintMistyValleyScenery(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final valleyBack = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.25, h * 0.66, w * 0.52, h * 0.75)
      ..quadraticBezierTo(w * 0.78, h * 0.82, w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      valleyBack,
      Paint()..color = const Color(0xFF1E222B).withValues(alpha: 0.6),
    );

    final valleyFront = Path()
      ..moveTo(0, h * 0.84)
      ..quadraticBezierTo(w * 0.45, h * 0.78, w, h * 0.86)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      valleyFront,
      Paint()..color = const Color(0xFF111318).withValues(alpha: 0.9),
    );
  }

  void _paintFantasyHighlandsScenery(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Aura bulan emas lembut di pojok atas
    final moonCenter = Offset(w * 0.80, h * 0.20);
    final moonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD4AF37).withValues(alpha: 0.22),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: w * 0.34));
    canvas.drawCircle(moonCenter, w * 0.34, moonGlow);
    canvas.drawCircle(
      moonCenter,
      20,
      Paint()..color = const Color(0xFFF3EFE6).withValues(alpha: 0.25),
    );

    // Perbukitan jauh
    final hillBack = Path()
      ..moveTo(0, h * 0.76)
      ..quadraticBezierTo(w * 0.28, h * 0.65, w * 0.56, h * 0.74)
      ..quadraticBezierTo(w * 0.82, h * 0.80, w, h * 0.69)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      hillBack,
      Paint()..color = const Color(0xFF1C172B).withValues(alpha: 0.65),
    );

    // Siluet kastil kecil di bukit kiri
    final castlePaint = Paint()
      ..color = const Color(0xFF130F1F).withValues(alpha: 0.85);
    final cx = w * 0.26;
    final cy = h * 0.695;
    canvas.drawRect(Rect.fromLTWH(cx - 18, cy - 22, 36, 28), castlePaint);
    canvas.drawRect(Rect.fromLTWH(cx - 22, cy - 34, 9, 40), castlePaint);
    canvas.drawRect(Rect.fromLTWH(cx + 13, cy - 30, 9, 36), castlePaint);

    // Perbukitan depan
    final hillFront = Path()
      ..moveTo(0, h * 0.86)
      ..quadraticBezierTo(w * 0.42, h * 0.79, w, h * 0.88)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      hillFront,
      Paint()..color = const Color(0xFF0D0B14).withValues(alpha: 0.95),
    );
  }

  // ==================== TEMPERATURE & WEATHER PARTICLES ====================

  void _paintTemperatureLayer(Canvas canvas, Size size, double temp) {
    if (temp >= 31) {
      final intensity = temp >= 35 ? 1.0 : 0.6;
      final auraPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 1.1),
          radius: 1.0,
          colors: [
            const Color(0xFFEA580C).withValues(alpha: 0.24 * intensity),
            const Color(0xFFFB923C).withValues(alpha: 0.08 * intensity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), auraPaint);

      final emberPaint = Paint()..style = PaintingStyle.fill;
      for (final p in tempParticles) {
        final dy = (p.y - progress * p.speed * 1.6) % 1.0;
        final yPos = (dy < 0 ? dy + 1.0 : dy) * size.height;
        final xPos =
            ((p.x + sin(progress * pi * 4 + p.phase) * 0.03) % 1.0) *
            size.width;
        final fade = (yPos / size.height).clamp(0.0, 1.0);

        emberPaint.color = const Color(0xFFFB923C)
            .withValues(alpha: 0.55 * fade * intensity);
        canvas.drawCircle(Offset(xPos, yPos), p.size * 0.9, emberPaint);
      }
    } else if (temp <= 15) {
      final intensity = temp <= 5 ? 1.0 : 0.55;
      final frostPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.9),
          radius: 1.1,
          colors: [
            const Color(0xFF38BDF8).withValues(alpha: 0.20 * intensity),
            const Color(0xFF7DD3FC).withValues(alpha: 0.06 * intensity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), frostPaint);

      final crystalPaint = Paint()..style = PaintingStyle.fill;
      for (final p in tempParticles) {
        final yPos = ((p.y + progress * p.speed * 0.6) % 1.0) * size.height;
        final xPos =
            ((p.x + cos(progress * pi * 2 + p.phase) * 0.04) % 1.0) *
            size.width;
        final twinkle = 0.5 + 0.5 * sin(progress * pi * 6 + p.phase);

        crystalPaint.color = const Color(0xFFBAE6FD)
            .withValues(alpha: 0.4 * twinkle * intensity);
        canvas.drawCircle(Offset(xPos, yPos), p.size * 0.8, crystalPaint);
      }
    }
  }

  void _paintArcaneMotes(
    Canvas canvas,
    Size size, {
    double opacityScale = 1.0,
  }) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in weatherParticles) {
      final dy = (p.y - progress * p.speed * 0.5) % 1.0;
      final yPos = (dy < 0 ? dy + 1.0 : dy) * size.height;
      final xPos =
          ((p.x + sin(progress * pi * 2 + p.phase) * 0.03) % 1.0) * size.width;
      final twinkle =
          0.35 + 0.65 * (0.5 + 0.5 * sin(progress * pi * 8 + p.phase));

      paint.color = const Color(0xFFD4AF37)
          .withValues(alpha: 0.35 * twinkle * opacityScale);
      canvas.drawCircle(Offset(xPos, yPos), p.size * 0.85, paint);
    }
  }

  void _paintMist(Canvas canvas, Size size, {required bool dense}) {
    final count = dense ? 6 : 3;
    for (int i = 0; i < count; i++) {
      final speed = 0.25 + (i * 0.08);
      final xOffset = ((progress * speed + i * 0.3) % 1.6 - 0.3) * size.width;
      final yPos = size.height * (0.15 + i * 0.14);
      final radius = size.width * (dense ? 0.55 : 0.45);

      final paint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(0xFF94A3B8).withValues(alpha: dense ? 0.14 : 0.08),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(xOffset, yPos), radius: radius),
            );

      canvas.drawCircle(Offset(xOffset, yPos), radius, paint);
    }
  }

  void _paintRain(Canvas canvas, Size size, {required bool heavy}) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = heavy ? 1.4 : 1.0;

    final dropCount = heavy ? weatherParticles.length : 25;
    for (int i = 0; i < dropCount; i++) {
      final p = weatherParticles[i];
      final speedMult = heavy ? 5.5 : 3.2;
      final yPos = ((p.y + progress * p.speed * speedMult) % 1.0) * size.height;
      final xPos = ((p.x + progress * 0.6) % 1.0) * size.width;
      final dropLen = heavy ? 18.0 + p.size * 3 : 10.0 + p.size * 2;

      paint.color = const Color(0xFF38BDF8)
          .withValues(alpha: heavy ? 0.28 : 0.18);
      canvas.drawLine(
        Offset(xPos, yPos),
        Offset(xPos - (heavy ? 4 : 2), yPos + dropLen),
        paint,
      );
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in weatherParticles) {
      final yPos = ((p.y + progress * p.speed * 1.4) % 1.0) * size.height;
      final xPos =
          ((p.x + sin(progress * pi * 4 + p.phase) * 0.05) % 1.0) * size.width;

      paint.color = const Color(0xFFE0F2FE).withValues(alpha: 0.45);
      canvas.drawCircle(Offset(xPos, yPos), p.size, paint);
    }
  }

  void _paintLightning(Canvas canvas, Size size) {
    final cycle = (progress * 3) % 1.0;
    if ((cycle > 0.72 && cycle < 0.745) || (cycle > 0.76 && cycle < 0.775)) {
      final flashPaint = Paint()
        ..color = const Color(0xFFE9D5FF).withValues(alpha: 0.16);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherBackdropPainter oldDelegate) => true;
}
