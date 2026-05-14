import 'package:dart_weather_xxx/forecast_provider.dart';
import 'package:dart_weather_xxx/location_provider.dart';
// take care: next line would lead to error "Can't use a relative path to import a library in 'lib'."
// see https://gemini.google.com/share/f3d605a58226
//import '../lib/forecast_provider.dart';

void main(List<String> arguments) async {
  var locationProvider = LocationProvider();
  locationProvider.selectLocation("Sydney");
  var forecastProvider = ForecastProvider(locationProvider);

  bool succeeded = await forecastProvider.fetchHourlyForecast();
  if (!succeeded) {
    print("fetchHourlyForecast did not succeed.");
    return;
  }

  print("this is the forecast for ${locationProvider.selectedLocation.name}:");
  for (var e in forecastProvider.hourlyForecast) {
    print("${e.localTime}: ${e.temp}°C, ${e.precipAmount}mm, ${e.cloudCover}%");
  }
}
