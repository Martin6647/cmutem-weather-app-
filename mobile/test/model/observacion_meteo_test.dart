import 'package:flutter_test/flutter_test.dart';
import 'package:weather/model/observacion_meteo.dart';

void main() {
  group('ObservacionMeteo', () {
    test('Debe mapear correctamente desde un JSON válido', () {
      final json = {
        'id_observacion': 'obs-123',
        'temperatura': 25.5,
        'humedad': 60.0,
        'ultravioleta': 5,
        'velocidad_viento': 12.5,
        'presion': 1013.2,
        'precipitacion': 0.0,
      };

      final clima = ObservacionMeteo.fromJson(json);

      expect(clima.idObservacion, 'obs-123');
      expect(clima.temperatura, 25.5);
      expect(clima.humedad, 60.0);
      expect(clima.ultravioleta, 5);
      expect(clima.velocidadViento, 12.5);
      expect(clima.presion, 1013.2);
      expect(clima.precipitacion, 0.0);
    });

    test('Debe manejar valores nulos con seguridad', () {
      final jsonVacio = <String, dynamic>{};
      final clima = ObservacionMeteo.fromJson(jsonVacio);

      expect(clima.idObservacion, null);
      expect(clima.temperatura, 0.0);
      expect(clima.humedad, 0.0);
      expect(clima.ultravioleta, 0);
      expect(clima.velocidadViento, 0.0);
    });
  });
}
