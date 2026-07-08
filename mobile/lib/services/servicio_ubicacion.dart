import 'package:geolocator/geolocator.dart';
import 'package:weather/model/coordenada.dart';

/// Servicio para obtener la ubicación actual del dispositivo.
///
/// Esta clase utiliza el paquete [geolocator] para gestionar el acceso
/// a los servicios de ubicación del sistema operativo. Maneja todo el
/// flujo necesario: verificación de servicios habilitados, solicitud de
/// permisos y obtención de la posición con alta precisión.
///
/// ## Flujo de obtención de ubicación
/// 1. **Verificar servicios de ubicación**: Comprueba si el GPS o el
///    proveedor de red están activos en el dispositivo.
/// 2. **Verificar permisos**: Consulta el estado actual de los permisos
///    de ubicación (`checkPermission`).
/// 3. **Solicitar permisos si es necesario**: Si el permiso fue denegado
///    previamente, se solicita al usuario (`requestPermission`).
/// 4. **Obtener posición**: Con los servicios activos y permisos otorgados,
///    obtiene la posición actual con una precisión alta.
/// 5. **Retornar coordenadas**: Convierte la posición en un objeto [Coordenada].
///
/// ## Manejo de errores
/// - Si los servicios de ubicación están deshabilitados, lanza una [Exception]
///   con el mensaje: *"Los servicios de ubicación están deshabilitados"*.
/// - Si el permiso fue denegado permanentemente (el usuario seleccionó "no
///   volver a preguntar"), lanza una [Exception] con el mensaje:
///   *"Permisos de ubicación denegados permanentemente"*.
/// - Si el usuario deniega el permiso después de solicitarlo, lanza una [Exception]
///   con el mensaje: *"Permisos de ubicación denegados por el usuario"*.
/// - Cualquier otro error (como fallo en la obtención de la posición) se propaga
///   como [Exception] desde [Geolocator.getCurrentPosition].
///
/// ## Consideraciones de plataforma
/// - **Android**: Se requiere el permiso `android.permission.ACCESS_FINE_LOCATION`
///   en el archivo `AndroidManifest.xml`.
/// - **iOS**: Se requiere agregar la clave `NSLocationWhenInUseUsageDescription`
///   o `NSLocationAlwaysUsageDescription` en el archivo `Info.plist`.
///
/// ## Ejemplo de uso
/// ```dart
/// final servicio = ServicioUbicacion();
/// try {
///   final coordenada = await servicio.obtenerUbicacionActual();
///   print('Ubicación: ${coordenada.latitud}, ${coordenada.longitud}');
/// } on Exception catch (e) {
///   print('Error al obtener ubicación: $e');
/// }
/// ```
///
/// ## Dependencias
/// - [geolocator]: Paquete para acceder a servicios de ubicación.
/// - [Coordenada]: Modelo que encapsula latitud y longitud.
///
/// ## Notas de implementación
/// - La precisión de la ubicación se configura como `LocationAccuracy.high`,
///   lo que prioriza la exactitud sobre el consumo de batería.
/// - El método `getCurrentPosition` usa las configuraciones por defecto de
///   [LocationSettings] (sin tiempo de espera adicional).
/// - El manejo de permisos sigue el patrón recomendado por el paquete
///   `geolocator` para solicitar permisos solo cuando es necesario.
///
/// ## Mejoras potenciales
/// - Agregar un timeout personalizado para la obtención de ubicación
///   (actualmente usa el default del sistema).
/// - Permitir elegir entre alta precisión y bajo consumo energético
///   mediante un parámetro en el método.
/// - Soportar la obtención de la última ubicación conocida antes de
///   solicitar una nueva, para mejorar el rendimiento.
class ServicioUbicacion {
  /// Obtiene la ubicación actual del dispositivo.
  ///
  /// Ejecuta el flujo completo de verificación y solicitud de permisos,
  /// y retorna las coordenadas como un objeto [Coordenada].
  ///
  /// ## Parámetros
  /// Este método no recibe parámetros; utiliza la configuración predeterminada
  /// de [Geolocator] para obtener la posición con alta precisión.
  ///
  /// ## Retorna
  /// Un [Coordenada] con la latitud y longitud actuales.
  ///
  /// ## Lanza
  /// [Exception] con mensajes descriptivos en los siguientes casos:
  /// - Los servicios de ubicación están desactivados.
  /// - El permiso de ubicación fue denegado permanentemente.
  /// - El usuario deniega el permiso al solicitarlo.
  /// - Fallo al obtener la posición (error de GPS, timeout, etc.).
  ///
  /// ## Ejemplo:
  /// ```dart
  /// final servicio = ServicioUbicacion();
  /// final coord = await servicio.obtenerUbicacionActual();
  /// ```
  Future<Coordenada> obtenerUbicacionActual() async {
    final bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      throw Exception('Los servicios de ubicación están deshabilitados');
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.deniedForever) {
      throw Exception('Permisos de ubicación denegados permanentemente');
    }

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw Exception('Permisos de ubicación denegados por el usuario');
      }
    }

    final Position posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return Coordenada(latitud: posicion.latitude, longitud: posicion.longitude);
  }
}
