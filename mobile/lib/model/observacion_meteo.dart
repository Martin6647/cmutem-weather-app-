/// Representa una observación meteorológica completa obtenida de la API.
///
/// Contiene todos los parámetros climáticos relevantes para una estación
/// y momento específicos. Esta clase se utiliza para transferir datos
/// desde el servicio REST y mostrarlos en la interfaz de usuario.
///
/// ## Ejemplo de uso
/// ```dart
/// final observacion = ObservacionMeteo(
///   direccionViento: 180.0,
///   fechaHora: DateTime.now(),
///   humedad: 65.0,
///   idObservacion: 'obs_123',
///   lluviadiaria: 2.5,
///   precipitacion: 0.0,
///   presion: 1013.0,
///   presionAbsoluta: 1015.0,
///   puntoRocio: 12.0,
///   rachaViento: 15.0,
///   radiacionSolar: 350.0,
///   tasalluvia: 0.0,
///   temperatura: 22.5,
///   ultravioleta: 5.0,
///   velocidadViento: 8.0,
/// );
/// ```
///
/// ## Nota sobre mutabilidad
/// Todos los campos son mutables (no `final`) para permitir actualizaciones
/// parciales si la API devuelve datos actualizados. Si se prefiere inmutabilidad,
/// se recomienda usar `copyWith` o convertir a un objeto inmodificable.
class ObservacionMeteo {
  /// Dirección del viento en grados (°), de 0 a 360.
  ///
  /// 0° indica viento del norte, 90° del este, 180° del sur, 270° del oeste.
  double direccionViento;

  /// Fecha y hora de la observación (UTC, según la API).
  DateTime fechaHora;

  /// Humedad relativa en porcentaje (0-100%).
  double humedad;

  /// Identificador único de la observación en la base de datos.
  String idObservacion;

  /// Precipitación acumulada del día en milímetros (mm).
  double lluviadiaria;

  /// Precipitación en el momento de la observación, generalmente en mm/h.
  double precipitacion;

  /// Presión atmosférica relativa al nivel del mar en hectopascales (hPa).
  double presion;

  /// Presión atmosférica absoluta en el lugar (sin ajuste por altitud) en hPa.
  double presionAbsoluta;

  /// Punto de rocío en grados Celsius (°C).
  double puntoRocio;

  /// Racha máxima de viento en el período reciente, en km/h o m/s (según API).
  double rachaViento;

  /// Radiación solar en vatios por metro cuadrado (W/m²).
  double radiacionSolar;

  /// Tasa de lluvia actual en mm/h (intensidad de precipitación).
  double tasalluvia;

  /// Temperatura en grados Celsius (°C).
  double temperatura;

  /// Índice de radiación ultravioleta (0-11+), escala estándar.
  double ultravioleta;

  /// Velocidad media del viento en km/h o m/s (según API).
  double velocidadViento;

  /// Constructor completo con todos los campos requeridos.
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

  /// Crea una instancia de [ObservacionMeteo] a partir de un mapa JSON.
  ///
  /// Espera las claves con nombres en formato snake_case, como las devueltas
  /// por la API. Convierte los valores numéricos a `double` y la fecha a
  /// [DateTime] usando [DateTime.parse].
  ///
  /// ## Claves esperadas
  /// - `"direccion_viento"` → [direccionViento]
  /// - `"fecha_hora"` → [fechaHora]
  /// - `"humedad"` → [humedad]
  /// - `"id_observacion"` → [idObservacion]
  /// - `"lluviadiaria"` → [lluviadiaria]
  /// - `"precipitacion"` → [precipitacion]
  /// - `"presion"` → [presion]
  /// - `"presion_absoluta"` → [presionAbsoluta]
  /// - `"punto_rocio"` → [puntoRocio]
  /// - `"racha_viento"` → [rachaViento]
  /// - `"radiacion_solar"` → [radiacionSolar]
  /// - `"tasalluvia"` → [tasalluvia]
  /// - `"temperatura"` → [temperatura]
  /// - `"ultravioleta"` → [ultravioleta]
  /// - `"velocidad_viento"` → [velocidadViento]
  ///
  /// ## Ejemplo:
  /// ```dart
  /// final json = {
  ///   'direccion_viento': 180.0,
  ///   'fecha_hora': '2026-07-08T10:00:00Z',
  ///   // ... resto de campos
  /// };
  /// final obs = ObservacionMeteo.fromJson(json);
  /// ```
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

  /// Convierte esta instancia a un mapa JSON con claves en snake_case.
  ///
  /// La fecha se serializa a formato ISO 8601 mediante [DateTime.toIso8601String].
  /// Todas las claves coinciden con las esperadas por el endpoint de la API.
  Map<String, dynamic> toJson() => {
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
