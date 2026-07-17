/// Clase para mapear los datos del clima que recibimos de la API.
class ObservacionMeteo {
  final String? idObservacion;
  final double temperatura;
  final double humedad;
  final double velocidadViento;
  final double presion;
  final double precipitacion;
  final double ultravioleta;

  ObservacionMeteo({
    this.idObservacion,
    required this.temperatura,
    required this.humedad,
    required this.velocidadViento,
    required this.presion,
    required this.precipitacion,
    required this.ultravioleta,
  });

  /// Función para estructurar los datos del JSON.
  /// Se encarga de arreglar problemas de la API (como recibir enteros en vez de decimales).
  /// Si el dato es nulo, asigna un valor de control (-30000.0) para evitar que la aplicación se caiga.
  factory ObservacionMeteo.fromJson(Map<String, dynamic> json) {
    double parseDato(dynamic valor) {
      if (valor == null) {
        return -30000.0;
      }
      if (valor is num) {
        return valor.toDouble();
      }
      if (valor is String) {
        return double.tryParse(valor) ?? -30000.0;
      }
      return -30000.0;
    }

    return ObservacionMeteo(
      idObservacion: json['id_observacion']?.toString(),
      temperatura: parseDato(json['temperatura']),
      humedad: parseDato(json['humedad']),
      velocidadViento: parseDato(json['velocidad_viento']),
      presion: parseDato(json['presion']),
      precipitacion: parseDato(json['precipitacion']),
      ultravioleta: parseDato(json['ultravioleta']),
    );
  }
}
