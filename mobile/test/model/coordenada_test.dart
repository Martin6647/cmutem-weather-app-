import 'package:flutter_test/flutter_test.dart';
import 'package:weather/model/coordenada.dart';

void main() {
  group('Coordenada', () {
    group('constructor', () {
      test('debe crear coordenada con valores válidos', () {
        final coordenada = Coordenada(
          latitud: -33.4489,
          longitud: -70.6693,
        );

        expect(coordenada.latitud, equals(-33.4489));
        expect(coordenada.longitud, equals(-70.6693));
      });

      test('debe permitir coordenadas en el Ecuador', () {
        final coordenada = Coordenada(
          latitud: 0,
          longitud: 0,
        );

        expect(coordenada.latitud, equals(0));
        expect(coordenada.longitud, equals(0));
      });

      test('debe permitir coordenadas en polos', () {
        final coordenada1 = Coordenada(
          latitud: 90,
          longitud: 0,
        );
        final coordenada2 = Coordenada(
          latitud: -90,
          longitud: 0,
        );

        expect(coordenada1.latitud, equals(90));
        expect(coordenada2.latitud, equals(-90));
      });

      test('debe permitir longitudes en los extremos', () {
        final coordenada1 = Coordenada(
          latitud: 0,
          longitud: 180,
        );
        final coordenada2 = Coordenada(
          latitud: 0,
          longitud: -180,
        );

        expect(coordenada1.longitud, equals(180));
        expect(coordenada2.longitud, equals(-180));
      });
    });

    group('igualdad', () {
      test('dos coordenadas const con mismos valores son iguales', () {
        const coordenada1 =
            Coordenada(latitud: -33.4489, longitud: -70.6693);
        const coordenada2 =
            Coordenada(latitud: -33.4489, longitud: -70.6693);

        expect(identical(coordenada1, coordenada2), isTrue);
      });

      test('dos coordenadas con mismos valores tienen propiedades iguales', () {
        final coordenada1 =
            Coordenada(latitud: -33.4489, longitud: -70.6693);
        final coordenada2 =
            Coordenada(latitud: -33.4489, longitud: -70.6693);

        expect(coordenada1.latitud, equals(coordenada2.latitud));
        expect(coordenada1.longitud, equals(coordenada2.longitud));
      });

      test('coordenadas con valores diferentes tienen propiedades diferentes', () {
        final coordenada1 =
            Coordenada(latitud: -33.4489, longitud: -70.6693);
        final coordenada2 =
            Coordenada(latitud: -33.4490, longitud: -70.6693);

        expect(coordenada1.latitud, isNot(equals(coordenada2.latitud)));
      });
    });
  });
}
