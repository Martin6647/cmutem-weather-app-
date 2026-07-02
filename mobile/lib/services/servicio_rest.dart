import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:weather/model/observacion_meteo.dart';

/// Servicio REST para consumir la API de observaciones meteorológicas.
///
/// Maneja autenticación via token, timeouts configurables y
/// mapeo de excepciones a mensajes amigables para el usuario.
class ServicioRest {
  static final String _baseUrl = 'https://api.sebastian.cl/cmutem';
  static final Logger _logger = Logger();
  late final Dio _clienteHttp;

  ServicioRest() {
    final BaseOptions opciones = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 17),
      receiveTimeout: const Duration(seconds: 23),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _clienteHttp = Dio(opciones);
    _clienteHttp.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// Mapea excepciones de Dio a mensajes de usuario.
  ///
  /// El orden de verificación es crítico: primero timeouts (sin response),
  /// luego códigos HTTP específicos, finalmente errores genéricos.
  Exception _mapearExcepcion(DioException error) {
    // Primero verificar timeouts (no tienen response)
    if (error.type == DioExceptionType.connectionTimeout) {
      _logger.e('Timeout de conexión: ${error.message}');
      return Exception('No se pudo conectar con el servidor');
    }

    if (error.type == DioExceptionType.receiveTimeout) {
      _logger.e('Timeout de respuesta: ${error.message}');
      return Exception('El servidor tardó demasiado en responder');
    }

    if (error.type == DioExceptionType.cancel) {
      _logger.w('Petición cancelada');
      return Exception('La petición fue cancelada');
    }

    // Sin respuesta del servidor
    if (error.response == null) {
      _logger.e('Sin respuesta: ${error.message}');
      return Exception('No hay conexión con el servidor');
    }

    // Con respuesta - verificar códigos HTTP
    final int codigoEstado = error.response!.statusCode ?? 0;
    _logger.e('Error HTTP $codigoEstado: ${error.response?.data}');

    switch (codigoEstado) {
      case 400:
        return Exception('Los datos ingresados son incorrectos');
      case 401:
        return Exception('Las credenciales son incorrectas o han expirado');
      case 403:
        return Exception('No tiene permisos para acceder a este recurso');
      case 404:
        return Exception('No hay observaciones cercanas al punto dado');
      case 500:
      case 502:
      case 503:
        return Exception('Error interno del servidor. Intente más tarde');
      default:
        return Exception('Error inesperado (código $codigoEstado)');
    }
  }

  /// Obtiene la observación meteorológica más cercana a las coordenadas dadas.
  ///
  /// [idToken] Token de autenticación del usuario.
  /// [latitud] Coordenada latitud (-90 a 90).
  /// [longitud] Coordenada longitud (-180 a 180).
  ///
  /// Retorna [ObservacionMeteo] con los datos climáticos.
  /// Lanza [Exception] si hay error en la petición o respuesta inválida.
  Future<ObservacionMeteo> obtenerObservacionCercana({
    required String idToken,
    required double latitud,
    required double longitud,
  }) async {
    // Validación de parámetros
    if (latitud < -90 || latitud > 90) {
      throw Exception('Latitud inválida: debe estar entre -90 y 90');
    }
    if (longitud < -180 || longitud > 180) {
      throw Exception('Longitud inválida: debe estar entre -180 y 180');
    }

    final String ruta = '/v1/clima/$latitud/$longitud';

    try {
      // Configurar header de autenticación
      _clienteHttp.options.headers['Authorization'] = 'Bearer $idToken';

      _logger.i('Consultando observación en: $ruta');
      final Response<dynamic> respuesta = await _clienteHttp.get<dynamic>(ruta);

      // Validar estructura de respuesta
      if (respuesta.data == null) {
        throw Exception('La respuesta del servidor está vacía');
      }

      if (respuesta.data is! Map<String, dynamic>) {
        _logger.e(
          'Tipo de respuesta inesperado: ${respuesta.data.runtimeType}',
        );
        throw Exception('Formato de respuesta inesperado');
      }

      final Map<String, dynamic> json = respuesta.data as Map<String, dynamic>;

      try {
        return ObservacionMeteo.fromJson(json);
      } catch (e) {
        _logger.e('Error al parsear respuesta: $e');
        throw Exception('Error al procesar los datos de la observación');
      }
    } on DioException catch (e) {
      throw _mapearExcepcion(e);
    } catch (e) {
      _logger.e('Error inesperado: $e');
      rethrow;
    }
  }

  /// Cierra el cliente HTTP y libera recursos.
  void cerrar() {
    _clienteHttp.close(force: true);
    _logger.i('Cliente HTTP cerrado');
  }
}
