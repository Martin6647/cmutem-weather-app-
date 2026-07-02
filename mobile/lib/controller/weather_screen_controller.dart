import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:weather/model/coordenada.dart';
import 'package:weather/model/observacion_meteo.dart';
import 'package:weather/services/servicio_google.dart';
import 'package:weather/services/servicio_rest.dart';
import 'package:weather/services/servicio_ubicacion.dart';

/// Controlador de la pantalla principal del clima.
///
/// Orquesta la obtención de ubicación, autenticación y consulta
/// meteorológica. Expone el estado de la UI mediante ChangeNotifier
/// para que los widgets reaccionen a cambios en carga, datos y errores.
///
/// Flujo de inicialización:
/// 1. Obtiene token de autenticación de Google.
/// 2. Solicita ubicación actual del dispositivo.
/// 3. Consulta observación meteorológica cercana.
///
/// Nota: Esta implementación usa Exception genérica en lugar de
/// excepciones personalizadas, simplificando el código pero limitando
/// el manejo específico por tipo de error.
class WeatherScreenController extends ChangeNotifier {
  static final Logger _logger = Logger();

  final ServicioRest _servicioRest;
  final ServicioUbicacion _servicioUbicacion;
  final ServicioGoogle _servicioGoogle;

  Coordenada? _coordenadaActual;
  ObservacionMeteo? _observacionMeteo;
  String? _mensajeError;
  bool _estaCargando = false;

  WeatherScreenController({
    required this._servicioRest,
    required this._servicioUbicacion,
    required this._servicioGoogle,
  });

  bool get estaCargando => _estaCargando;

  /// Mensaje de error actual. Null indica que no hay error.
  String? get mensajeError => _mensajeError;

  ObservacionMeteo? get observacionMeteo => _observacionMeteo;

  Coordenada? get coordenadaActual => _coordenadaActual;

  /// Indica si hay datos suficientes para mostrar la pantalla principal.
  bool get tieneDatos => _observacionMeteo != null && _coordenadaActual != null;

  /// Inicializa los datos de la pantalla ejecutando el flujo completo.
  ///
  /// Establece el estado de carga, obtiene token, ubicación y observación.
  /// En caso de error, captura la excepción y expone su mensaje
  /// a través de [mensajeError].
  Future<void> inicializarDatos() async {
    _estaCargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final String idToken = await _obtenerTokenValido();
      _coordenadaActual = await _servicioUbicacion.obtenerUbicacionActual();
      _observacionMeteo = await _servicioRest.obtenerObservacionCercana(
        idToken: idToken,
        latitud: _coordenadaActual!.latitud,
        longitud: _coordenadaActual!.longitud,
      );
      _logger.i(
        'Datos inicializados correctamente en '
        '${_coordenadaActual!.latitud}, ${_coordenadaActual!.longitud}',
      );
    } catch (error) {
      _manejarError(error);
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  /// Reintenta la carga de datos desde cero.
  ///
  /// Útil cuando el usuario presiona "Reintentar" tras un error.
  Future<void> reintentar() async {
    _logger.i('Reintentando carga de datos');
    await inicializarDatos();
  }

  /// Limpia el mensaje de error actual.
  ///
  /// Permite a la UI ocultar banners de error sin recargar datos.
  void limpiarError() {
    if (_mensajeError != null) {
      _mensajeError = null;
      notifyListeners();
    }
  }

  /// Obtiene y valida el token de autenticación.
  ///
  /// Lanza [Exception] si el token es nulo o vacío,
  /// evitando peticiones que fallarían con 401.
  Future<String> _obtenerTokenValido() async {
    final String? token = await _servicioGoogle.obtenerToken();

    if (token == null || token.isEmpty) {
      _logger.w('Token de autenticación ausente o vacío');
      throw Exception('No se pudo obtener el token de autenticación');
    }

    return token;
  }

  /// Registra el error y establece el mensaje para la UI.
  ///
  /// Extrae el mensaje de la excepción y lo asigna a [_mensajeError].
  /// Si la excepción no tiene mensaje, usa un texto genérico.
  void _manejarError(Object error) {
    String mensajeExtraido;

    if (error is Exception) {
      // Extraer mensaje de Exception.toString()
      final String errorString = error.toString();
      // Exception.toString() retorna "Exception: mensaje"
      // Extraemos solo el mensaje después de "Exception: "
      if (errorString.startsWith('Exception: ')) {
        mensajeExtraido = errorString.substring(11);
      } else {
        mensajeExtraido = errorString;
      }
    } else {
      mensajeExtraido = 'Error inesperado: ${error.toString()}';
    }

    _mensajeError = mensajeExtraido;
    _logger.e('Error durante inicialización', error: error);
  }

  @override
  void dispose() {
    _logger.i('Dispose del controlador de clima');
    super.dispose();
  }
}
