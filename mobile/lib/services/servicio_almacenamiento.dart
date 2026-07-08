import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:weather/consts/app_const.dart';

/// Servicio utilitario para gestionar el almacenamiento seguro de datos del usuario.
///
/// Esta clase proporciona métodos estáticos para leer valores almacenados de forma
/// segura utilizando [FlutterSecureStorage], una solución que cifra los datos
/// en disco (Keychain en iOS, Keystore en Android). Centraliza el acceso a las
/// claves definidas en [AppConst], facilitando el mantenimiento y evitando errores
/// de escritura.
///
/// ## Propósito
/// - **Seguridad**: Los datos sensibles (tokens, email, etc.) se almacenan cifrados.
/// - **Centralización**: Todas las lecturas de almacenamiento seguro usan esta clase.
/// - **Manejo de errores**: Captura excepciones y retorna valores por defecto (cadena vacía).
/// - **Logging**: Registra errores con [Logger] para facilitar la depuración.
///
/// ## Métodos disponibles
/// - [obtenerEmail]: Recupera el correo electrónico del usuario.
/// - [obtenerNombre]: Recupera el nombre del usuario.
/// - [obtenerUrlFoto]: Recupera la URL de la foto de perfil.
///
/// ## Ejemplo de uso
/// ```dart
/// // Obtener datos del usuario
/// final email = await ServicioAlmacenamiento.obtenerEmail();
/// final nombre = await ServicioAlmacenamiento.obtenerNombre();
/// final fotoUrl = await ServicioAlmacenamiento.obtenerUrlFoto();
///
/// if (email.isNotEmpty) {
///   print('Usuario: $nombre ($email)');
/// }
/// ```
///
/// ## Notas de implementación
/// - Todos los métodos son `static`, por lo que no es necesario instanciar la clase.
/// - El constructor es implícito y público, pero al ser una clase utilitaria
///   no se recomienda instanciarla. Se podría hacer privado para reforzar su uso
///   estático, pero se mantiene así por simplicidad.
/// - Los valores se retornan como `String`. Si la clave no existe o ocurre un error,
///   se retorna una cadena vacía (`''`).
/// - El almacenamiento se inicializa una sola vez como `static final`.
///
/// ## Posibles mejoras
/// - Agregar métodos para escribir/eliminar valores (actualmente solo lectura).
/// - Permitir configurar un tiempo de expiración o invalidación de caché.
/// - Inyectar una instancia de [FlutterSecureStorage] para facilitar pruebas unitarias.
/// - Añadir soporte para otros tipos de datos (int, bool, etc.) mediante serialización.
///
/// ## Dependencias
/// - [flutter_secure_storage]: Para almacenamiento cifrado.
/// - [logger]: Para registro de errores.
/// - [AppConst]: Para las claves de almacenamiento.
class ServicioAlmacenamiento {
  static final Logger _logger = Logger();
  static final FlutterSecureStorage _almacenamiento = FlutterSecureStorage();

  /// Obtiene un valor del almacenamiento seguro.
  ///
  /// Método interno que encapsula la lógica de lectura, manejo de errores
  /// y logging para cualquier clave.
  ///
  /// Parámetros:
  /// - [clave]: Identificador de la clave (definido en [AppConst]).
  /// - [nombrePropiedad]: Texto descriptivo para los logs (ej: "email del usuario").
  ///
  /// Retorna:
  /// - El valor almacenado como `String`, o una cadena vacía (`''`) si:
  ///   - La clave no existe en el almacenamiento.
  ///   - Ocurre una excepción durante la lectura.
  ///
  /// ## Ejemplo interno:
  /// ```dart
  /// final email = await _obtenerValor(AppConst.etiquetaEmail, 'email');
  /// ```
  static Future<String> _obtenerValor(
    String clave,
    String nombrePropiedad,
  ) async {
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

  /// Obtiene el correo electrónico del usuario autenticado.
  ///
  /// Lee el valor almacenado bajo la clave [AppConst.etiquetaEmail].
  ///
  /// Retorna:
  /// - El email como `String`, o una cadena vacía si no está disponible.
  ///
  /// ## Ejemplo:
  /// ```dart
  /// final email = await ServicioAlmacenamiento.obtenerEmail();
  /// if (email.isNotEmpty) {
  ///   // Usar email
  /// }
  /// ```
  static Future<String> obtenerEmail() =>
      _obtenerValor(AppConst.etiquetaEmail, 'email');

  /// Obtiene el nombre del usuario autenticado.
  ///
  /// Lee el valor almacenado bajo la clave [AppConst.etiquetaNombre].
  ///
  /// Retorna:
  /// - El nombre como `String`, o una cadena vacía si no está disponible.
  ///
  /// ## Ejemplo:
  /// ```dart
  /// final nombre = await ServicioAlmacenamiento.obtenerNombre();
  /// ```
  static Future<String> obtenerNombre() =>
      _obtenerValor(AppConst.etiquetaNombre, 'nombre');

  /// Obtiene la URL de la foto de perfil del usuario autenticado.
  ///
  /// Lee el valor almacenado bajo la clave [AppConst.etiquetaUrlFoto].
  ///
  /// Retorna:
  /// - La URL como `String`, o una cadena vacía si no está disponible.
  ///
  /// ## Ejemplo:
  /// ```dart
  /// final fotoUrl = await ServicioAlmacenamiento.obtenerUrlFoto();
  /// if (fotoUrl.isNotEmpty) {
  ///   // Cargar imagen desde fotoUrl
  /// }
  /// ```
  static Future<String> obtenerUrlFoto() =>
      _obtenerValor(AppConst.etiquetaUrlFoto, 'URL de foto');
}
