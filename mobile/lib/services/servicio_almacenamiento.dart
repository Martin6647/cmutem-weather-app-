import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:weather/consts/app_const.dart';

class ServicioAlmacenamiento {
  static final Logger _logger = Logger();
  static final FlutterSecureStorage _almacenamiento = FlutterSecureStorage();

  /// Obtiene un valor del almacenamiento seguro.
  ///
  /// Parámetros:
  /// - [clave]: identificador en constantes AppConst
  /// - [nombrePropiedad]: texto descriptivo para logs (ej: "email del usuario")
  ///
  /// Retorna:
  /// - El valor almacenado, o string vacío si no existe o falla.
  static Future<String> _obtenerValor(String clave, String nombrePropiedad) async {
    try {
      final String? valor = await _almacenamiento.read(key: clave);
      return valor ?? '';
    } catch (error) {
      _logger.e(
        'Error al obtener $nombrePropiedad desde almacenamiento',
        error: error,
      );
      return '';
    }
  }

  /// Obtiene el email del usuario autenticado.
  static Future<String> obtenerEmail() =>
      _obtenerValor(AppConst.etiquetaEmail, 'email');

  /// Obtiene el nombre del usuario autenticado.
  static Future<String> obtenerNombre() =>
      _obtenerValor(AppConst.etiquetaNombre, 'nombre');

  /// Obtiene la URL de la foto del usuario.
  static Future<String> obtenerUrlFoto() =>
      _obtenerValor(AppConst.etiquetaUrlFoto, 'URL de foto');
}
