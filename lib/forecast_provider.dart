import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'weather_data.dart';

class ForecastProvider {
  List<WeatherData> hourlyForecast = [];
  bool _initialized = false;

  void _initialize() {
    tz.initializeTimeZones();
  }

  Future<bool> fetchHourlyForecast() async {
    if (!_initialized) {
      _initialize();
      _initialized = true;
    }

    hourlyForecast.clear();

    // latitude and longitude of Schloß Johannisburg in Aschaffenburg
    var lat = 49.97606;
    var lon = 9.14163;

    // latitude and longitude for Sydney
    // var lat = -33.86785;
    // var lon = 151.20732;

    // 'https://api.open-meteo.com/v1/forecast?latitude=49.97606&longitude=9.14163&hourly=temperature_2m,precipitation,cloud_cover&forecast_days=1';
    final url =
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,precipitation,cloud_cover&forecast_days=1";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      print(
        "statusCode in response from open-meteo api was ${response.statusCode}",
      );
      return (false);
    }

    final data = jsonDecode(response.body);

    List<String> times = [];
    List<double?> temps = [];
    List<double?> precipAmounts = [];
    List<int?> cloudCovers = [];

    times = List<String>.from(data['hourly']['time']);
    temps = List<double?>.from(data['hourly']['temperature_2m']);
    precipAmounts = List<double?>.from(data['hourly']['precipitation']);
    cloudCovers = List<int?>.from(data['hourly']['cloud_cover']);

    var timezoneName = latLngToTimezoneString(lat, lon);
    final tzLocation = tz.getLocation(timezoneName);
    final nowInUtc = DateTime.now().toUtc();

    for (int i = 0; i < times.length; i++) {
      final timeInUtc = DateTime.parse("${times[i]}Z");
      if (timeInUtc.isAfter(nowInUtc)) {
        final localTime = tz.TZDateTime.from(timeInUtc, tzLocation);
        var data = WeatherData(localTime);
        data.temp = temps[i];
        data.precipAmount = precipAmounts[i];
        data.cloudCover = cloudCovers[i];
        hourlyForecast.add(data);
      }
    }
    return true;
  }
}
