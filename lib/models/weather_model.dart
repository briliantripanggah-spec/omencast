class WeatherModel {
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherModel({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final hourlyJson = json['hourly'] as Map<String, dynamic>?;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    // Parse Hourly (ambil 24 jam ke depan dari waktu sekarang)
    final List<HourlyForecast> hourlyList = [];
    if (hourlyJson != null) {
      final List<String> hTimes = List<String>.from(hourlyJson['time'] ?? []);
      final List<num> hTemps = List<num>.from(
        hourlyJson['temperature_2m'] ?? [],
      );
      final List<num> hProbs = List<num>.from(
        hourlyJson['precipitation_probability'] ?? [],
      );
      final List<num> hCodes = List<num>.from(hourlyJson['weather_code'] ?? []);

      final now = DateTime.now();
      int startIndex = 0;
      for (int i = 0; i < hTimes.length; i++) {
        final dt = DateTime.tryParse(hTimes[i]);
        if (dt != null &&
            !dt.isBefore(DateTime(now.year, now.month, now.day, now.hour))) {
          startIndex = i;
          break;
        }
      }

      final endIndex = (startIndex + 24).clamp(0, hTimes.length);
      for (int i = startIndex; i < endIndex; i++) {
        hourlyList.add(
          HourlyForecast(
            time: hTimes[i],
            temperature: hTemps[i].toDouble(),
            precipitationProbability: i < hProbs.length ? hProbs[i].toInt() : 0,
            weatherCode: i < hCodes.length ? hCodes[i].toInt() : 0,
          ),
        );
      }
    }

    // Parse Daily
    final List<String> dates = List<String>.from(dailyJson['time'] ?? []);
    final List<num> maxTemps = List<num>.from(
      dailyJson['temperature_2m_max'] ?? [],
    );
    final List<num> minTemps = List<num>.from(
      dailyJson['temperature_2m_min'] ?? [],
    );
    final List<num> rainProbs = List<num>.from(
      dailyJson['precipitation_probability_max'] ?? [],
    );
    final List<num> weatherCodes = List<num>.from(
      dailyJson['weather_code'] ?? [],
    );
    final List<String> sunrises = List<String>.from(dailyJson['sunrise'] ?? []);
    final List<String> sunsets = List<String>.from(dailyJson['sunset'] ?? []);
    final List<num> uvMaxes = List<num>.from(dailyJson['uv_index_max'] ?? []);

    final List<DailyForecast> dailyList = [];
    for (int i = 0; i < dates.length; i++) {
      dailyList.add(
        DailyForecast(
          date: dates[i],
          maxTemp: maxTemps[i].toDouble(),
          minTemp: minTemps[i].toDouble(),
          precipitationProbabilityMax: rainProbs[i].toInt(),
          weatherCode: weatherCodes[i].toInt(),
          sunrise: i < sunrises.length ? sunrises[i] : '',
          sunset: i < sunsets.length ? sunsets[i] : '',
          uvIndexMax: i < uvMaxes.length ? uvMaxes[i].toDouble() : 0.0,
        ),
      );
    }

    return WeatherModel(
      current: CurrentWeather.fromJson(currentJson),
      hourly: hourlyList,
      daily: dailyList,
    );
  }
}

class CurrentWeather {
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

class HourlyForecast {
  final String time;
  final double temperature;
  final int precipitationProbability;
  final int weatherCode;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.weatherCode,
  });
}

class DailyForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final int precipitationProbabilityMax;
  final int weatherCode;
  final String sunrise;
  final String sunset;
  final double uvIndexMax;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
  });
}
