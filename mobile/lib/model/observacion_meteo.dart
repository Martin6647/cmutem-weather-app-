class ObservacionMeteo {
  double direccionViento;
  DateTime fechaHora;
  double humedad;
  String idObservacion;
  double lluviadiaria;
  double precipitacion;
  double presion;
  double presionAbsoluta;
  double puntoRocio;
  double rachaViento;
  double radiacionSolar;
  double tasalluvia;
  double temperatura;
  double ultravioleta;
  double velocidadViento;

  ObservacionMeteo({
    required this.direccionViento,
    required this.fechaHora,
    required this.humedad,
    required this.idObservacion,
    required this.lluviadiaria,
    required this.precipitacion,
    required this.presion,
    required this.presionAbsoluta,
    required this.puntoRocio,
    required this.rachaViento,
    required this.radiacionSolar,
    required this.tasalluvia,
    required this.temperatura,
    required this.ultravioleta,
    required this.velocidadViento,
  });

  factory ObservacionMeteo.fromJson(Map<String, dynamic> json) =>
      ObservacionMeteo(
        direccionViento: json["direccion_viento"]?.toDouble(),
        fechaHora: DateTime.parse(json["fecha_hora"]),
        humedad: json["humedad"]?.toDouble(),
        idObservacion: json["id_observacion"],
        lluviadiaria: json["lluviadiaria"]?.toDouble(),
        precipitacion: json["precipitacion"]?.toDouble(),
        presion: json["presion"]?.toDouble(),
        presionAbsoluta: json["presion_absoluta"]?.toDouble(),
        puntoRocio: json["punto_rocio"]?.toDouble(),
        rachaViento: json["racha_viento"]?.toDouble(),
        radiacionSolar: json["radiacion_solar"]?.toDouble(),
        tasalluvia: json["tasalluvia"]?.toDouble(),
        temperatura: json["temperatura"]?.toDouble(),
        ultravioleta: json["ultravioleta"]?.toDouble(),
        velocidadViento: json["velocidad_viento"]?.toDouble(),
      );

  Map<String, dynamic> toJson() =>
      {
        "direccion_viento": direccionViento,
        "fecha_hora": fechaHora.toIso8601String(),
        "humedad": humedad,
        "id_observacion": idObservacion,
        "lluviadiaria": lluviadiaria,
        "precipitacion": precipitacion,
        "presion": presion,
        "presion_absoluta": presionAbsoluta,
        "punto_rocio": puntoRocio,
        "racha_viento": rachaViento,
        "radiacion_solar": radiacionSolar,
        "tasalluvia": tasalluvia,
        "temperatura": temperatura,
        "ultravioleta": ultravioleta,
        "velocidad_viento": velocidadViento,
      };
}