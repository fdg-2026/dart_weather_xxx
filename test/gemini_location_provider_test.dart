import 'package:test/test.dart';
import 'package:dart_weather_xxx/location_provider.dart';

void main() {
  group('LocationProvider Tests', () {
    late LocationProvider provider;

    setUp(() {
      provider = LocationProvider();
    });

    test('Initial selected location should be Aschaffenburg', () {
      expect(provider.selectedLocation.name, equals('Aschaffenburg'));
    });

    test('getLocationNames returns all defined names', () {
      final names = provider.getLocationNames();
      expect(names, contains('Sydney'));
      expect(names, contains('New York'));
      expect(names.length, equals(5));
    });

    test('selectLocation updates the selected location if name exists', () {
      final result = provider.selectLocation('Sydney');
      expect(result, isTrue);
      expect(provider.selectedLocation.name, equals('Sydney'));
    });

    test(
      'selectLocation returns false and does not change selection if name missing',
      () {
        final result = provider.selectLocation('Mars');
        expect(result, isFalse);
        expect(provider.selectedLocation.name, equals('Aschaffenburg'));
      },
    );
  });
}
