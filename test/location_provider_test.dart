import 'package:dart_weather_xxx/location_provider.dart';
import 'package:test/test.dart';

void main() {
  test('test selectLocation', () {
    var locationProvider = LocationProvider();
    // default is Aschaffenburg
    var location = locationProvider.selectedLocation;
    expect(location.name, "Aschaffenburg");

    var result = locationProvider.selectLocation("Sydney");
    expect(result, true);
    expect(locationProvider.selectedLocation.name, "Sydney");

    result = locationProvider.selectLocation("xxx");
    expect(result, false);
    expect(locationProvider.selectedLocation.name, "Sydney");
  });

  test('test getLocationNames', () {
    var locationProvider = LocationProvider();
    var names = locationProvider.getLocationNames();
    expect(names.length == 5, true);
  });
}
