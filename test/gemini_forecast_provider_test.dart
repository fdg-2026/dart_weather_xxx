import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dart_weather_xxx/forecast_provider.dart';
import 'package:dart_weather_xxx/location_provider.dart';

void main() {
  group('ForecastProvider Logic', () {
    late LocationProvider locationProvider;

    setUp(() {
      locationProvider = LocationProvider();
    });

    test('returns true and populates list on successful API call', () async {
      // 1. Create a Mock Client that returns a fake JSON response
      final mockClient = MockClient((request) async {
        final jsonResponse = {
          'hourly': {
            'time': ["2050-01-01T12:00", "2050-01-01T13:00"], // Future dates
            'temperature_2m': [25.0, 26.5],
            'precipitation': [0.0, 0.0],
            'cloud_cover': [0, 10],
          },
        };
        return http.Response(jsonEncode(jsonResponse), 200);
      });

      final forecastProvider = ForecastProvider(
        locationProvider,
        client: mockClient,
      );

      // 2. Execute
      final result = await forecastProvider.fetchHourlyForecast();

      // 3. Verify
      expect(result, isTrue);
      expect(forecastProvider.hourlyForecast.length, equals(2));
      expect(forecastProvider.hourlyForecast[0].temp, 25.0);
    });

    test('returns false when API returns 404 or 500', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final forecastProvider = ForecastProvider(
        locationProvider,
        client: mockClient,
      );
      final result = await forecastProvider.fetchHourlyForecast();

      expect(result, isFalse);
      expect(forecastProvider.hourlyForecast, isEmpty);
    });

    test('filters out past forecast times', () async {
      // This test ensures the "isAfter(nowInUtc)" logic works
      final mockClient = MockClient((request) async {
        final jsonResponse = {
          'hourly': {
            'time': [
              "2000-01-01T12:00",
              "2050-01-01T12:00",
            ], // One past, one future
            'temperature_2m': [10.0, 30.0],
            'precipitation': [0.0, 0.0],
            'cloud_cover': [0, 0],
          },
        };
        return http.Response(jsonEncode(jsonResponse), 200);
      });

      final forecastProvider = ForecastProvider(
        locationProvider,
        client: mockClient,
      );
      await forecastProvider.fetchHourlyForecast();

      // Should only contain the year 2050 entry
      expect(forecastProvider.hourlyForecast.length, equals(1));
      expect(forecastProvider.hourlyForecast[0].temp, 30.0);
    });
  });
}
