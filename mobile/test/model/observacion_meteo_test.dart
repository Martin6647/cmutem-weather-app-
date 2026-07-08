import 'package:flutter_test/flutter_test.dart';
import 'package:weather/model/observacion_meteo.dart';

void main() {
  group('ObservacionMeteo', () {
    group('constructor', () {
      test('debe crear observación con todos los parámetros válidos', () {
        final fechaHora = DateTime.now().toUtc();

        final observacion = ObservacionMeteo(
          direccionViento: 180.0,
          fechaHora: fechaHora,
          humedad: 65.0,
          idObservacion: 'obs_001',
          lluviadiaria: 0.5,
          precipitacion: 0.0,
          presion: 1013.25,
          presionAbsoluta: 1015.0,
          puntoRocio: 12.0,
          rachaViento: 15.0,
          radiacionSolar: 350.0,
          tasalluvia: 0.0,
          temperatura: 22.5,
          ultravioleta: 5.0,
          velocidadViento: 8.0,
        );

        expect(observacion.temperatura, equals(22.5));
        expect(observacion.humedad, equals(65.0));
        expect(observacion.presion, equals(1013.25));
        expect(observacion.velocidadViento, equals(8.0));
        expect(observacion.direccionViento, equals(180.0));
        expect(observacion.precipitacion, equals(0.0));
        expect(observacion.idObservacion, equals('obs_001'));
      });
    });

    group('conversor JSON', () {
      test('debe crear desde JSON correctamente', () {
        final json = {
          'direccion_viento': 180.0,
          'fecha_hora': '2026-07-08T10:00:00Z',
          'humedad': 65.0,
          'id_observacion': 'obs_001',
          'lluviadiaria': 0.5,
          'precipitacion': 0.0,
          'presion': 1013.25,
          'presion_absoluta': 1015.0,
          'punto_rocio': 12.0,
          'racha_viento': 15.0,
          'radiacion_solar': 350.0,
          'tasalluvia': 0.0,
          'temperatura': 22.5,
          'ultravioleta': 5.0,
          'velocidad_viento': 8.0,
        };

        final observacion = ObservacionMeteo.fromJson(json);

        expect(observacion.temperatura, equals(22.5));
        expect(observacion.humedad, equals(65.0));
        expect(observacion.idObservacion, equals('obs_001'));
      });

      test('debe convertir a JSON correctamente', () {
        final fechaHora = DateTime.utc(2026, 7, 8, 10, 0, 0);

        final observacion = ObservacionMeteo(
          direccionViento: 180.0,
          fechaHora: fechaHora,
          humedad: 65.0,
          idObservacion: 'obs_001',
          lluviadiaria: 0.5,
          precipitacion: 0.0,
          presion: 1013.25,
          presionAbsoluta: 1015.0,
          puntoRocio: 12.0,
          rachaViento: 15.0,
          radiacionSolar: 350.0,
          tasalluvia: 0.0,
          temperatura: 22.5,
          ultravioleta: 5.0,
          velocidadViento: 8.0,
        );

        final json = observacion.toJson();

        expect(json['temperatura'], equals(22.5));
        expect(json['humedad'], equals(65.0));
        expect(json['id_observacion'], equals('obs_001'));
      });

      test('debe convertir a JSON y desde JSON manteniendo datos', () {
        final fechaHora = DateTime.utc(2026, 7, 8, 10, 0, 0);

        final observacionOriginal = ObservacionMeteo(
          direccionViento: 180.0,
          fechaHora: fechaHora,
          humedad: 65.0,
          idObservacion: 'obs_001',
          lluviadiaria: 0.5,
          precipitacion: 0.0,
          presion: 1013.25,
          presionAbsoluta: 1015.0,
          puntoRocio: 12.0,
          rachaViento: 15.0,
          radiacionSolar: 350.0,
          tasalluvia: 0.0,
          temperatura: 22.5,
          ultravioleta: 5.0,
          velocidadViento: 8.0,
        );

        final json = observacionOriginal.toJson();
        final observacionRecuperada = ObservacionMeteo.fromJson(json);

        expect(observacionRecuperada.temperatura, equals(observacionOriginal.temperatura));
        expect(observacionRecuperada.humedad, equals(observacionOriginal.humedad));
        expect(observacionRecuperada.presion, equals(observacionOriginal.presion));
        expect(observacionRecuperada.velocidadViento, equals(observacionOriginal.velocidadViento));
      });
    });
  });
}
