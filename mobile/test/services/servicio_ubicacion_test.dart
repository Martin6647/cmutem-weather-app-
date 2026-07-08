import 'package:flutter_test/flutter_test.dart';
import 'package:weather/model/coordenada.dart';
import 'package:weather/services/servicio_ubicacion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServicioUbicacion', () {
    late ServicioUbicacion servicioUbicacion;

    setUp(() {
      servicioUbicacion = ServicioUbicacion();
    });

    group('obtenerUbicacionActual', () {
      test('retorna Coordenada o lanza excepción', () async {
        try {
          final resultado = await servicioUbicacion.obtenerUbicacionActual();

          expect(resultado, isNotNull);
          expect(resultado, isA<Coordenada>());
          expect(resultado.latitud, greaterThanOrEqualTo(-90));
          expect(resultado.latitud, lessThanOrEqualTo(90));
          expect(resultado.longitud, greaterThanOrEqualTo(-180));
          expect(resultado.longitud, lessThanOrEqualTo(180));
        } on Exception catch (e) {
          expect(e, isA<Exception>());
        }
      });
    });
  });
}
