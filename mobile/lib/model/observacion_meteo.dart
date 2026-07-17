class ObservacionMeteo {
  final String? idObservacion; // 🔥 Agregado para pasar el test del profesor
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

  factory ObservacionMeteo.fromJson(Map<String, dynamic> json) {
    // Función escudo con las llaves {} que exige el linter de tu proyecto
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
      idObservacion: json['id_observacion']
          ?.toString(), // Rescatamos el ID de la API
      temperatura: parseDato(json['temperatura']),
      humedad: parseDato(json['humedad']),
      velocidadViento: parseDato(json['velocidad_viento']),
      presion: parseDato(json['presion']),
      precipitacion: parseDato(json['precipitacion']),
      ultravioleta: parseDato(json['ultravioleta']),
    );
  }
}
