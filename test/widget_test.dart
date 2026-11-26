import 'package:flutter_test/flutter_test.dart';
import 'package:omencast/core/utils/weather_mapper.dart';

void main() {
  test('WeatherMapper returns Clear Sky for code 0', () {
    final info = WeatherMapper.fromCode(0);
    expect(info.label, 'Clear Sky');
  });
}
