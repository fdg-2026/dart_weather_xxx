import 'package:test/test.dart';
import 'package:dart_weather_xxx/forecast_provider.dart';
import 'package:dart_weather_xxx/location_provider.dart';

void main() {
  test('test forecast length', () async {
    var locationProvider = LocationProvider();
    var forecastProvider = ForecastProvider(locationProvider);

    var now = DateTime.now().toUtc();
    var currentHour = now.hour;

    bool succeeded = await forecastProvider.fetchHourlyForecast();
    expect(succeeded, true);
    expect(forecastProvider.hourlyForecast.length, 24 - currentHour - 1);
  });

  test('all forecasts start at the same UTC time', () async {
    var locationProvider = LocationProvider();
    var forecastProvider = ForecastProvider(locationProvider);

    bool succeeded = locationProvider.selectLocation("Sydney");
    expect(succeeded, true);
    succeeded = await forecastProvider.fetchHourlyForecast();
    expect(succeeded, true);
    var sydneyLocalTime = forecastProvider.hourlyForecast[0].localTime;

    succeeded = locationProvider.selectLocation("Aschaffenburg");
    expect(succeeded, true);
    succeeded = await forecastProvider.fetchHourlyForecast();
    expect(succeeded, true);
    var aschaffenburgLocalTime = forecastProvider.hourlyForecast[0].localTime;

    expect(
      sydneyLocalTime.microsecondsSinceEpoch ==
          aschaffenburgLocalTime.microsecondsSinceEpoch,
      true,
    );
  });

  test('enforce API error', () async {
    var locationProvider = LocationProvider();
    var forecastProvider = ForecastProvider(locationProvider);

    bool succeeded = locationProvider.selectLocation("invalid");
    expect(succeeded, true);
    succeeded = await forecastProvider.fetchHourlyForecast();
    expect(succeeded, false);
    expect(forecastProvider.hourlyForecast.length, 0);
  });
}
