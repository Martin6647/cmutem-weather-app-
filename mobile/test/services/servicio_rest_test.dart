import 'package:flutter_test/flutter_test.dart';
import 'package:weather/services/servicio_rest.dart';

void main() {
  group('ServicioRest', () {
    late ServicioRest servicioRest;

    setUp(() {
      servicioRest = ServicioRest();
    });

    tearDown(() {
      servicioRest.cerrar();
    });

    group('validaciones de parámetros', () {
      test('debe lanzar excepción con latitud > 90', () {
        const token = 'valid_token';

        expect(
          () => servicioRest.obtenerObservacionCercana(
            idToken: token,
            latitud: 91,
            longitud: -70.6693,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('debe lanzar excepción con latitud < -90', () {
        const token = 'valid_token';

        expect(
          () => servicioRest.obtenerObservacionCercana(
            idToken: token,
            latitud: -91,
            longitud: -70.6693,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('debe lanzar excepción con longitud > 180', () {
        const token = 'valid_token';

        expect(
          () => servicioRest.obtenerObservacionCercana(
            idToken: token,
            latitud: -33.4489,
            longitud: 181,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('debe lanzar excepción con longitud < -180', () {
        const token = 'valid_token';

        expect(
          () => servicioRest.obtenerObservacionCercana(
            idToken: token,
            latitud: -33.4489,
            longitud: -181,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
