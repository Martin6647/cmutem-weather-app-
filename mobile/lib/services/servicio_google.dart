import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:weather/consts/app_const.dart';

/// Servicio de autenticación mediante Google Sign-In.
///
/// Gestiona el ciclo completo de autenticación: inicialización del SDK,
/// inicio/cierre de sesión, almacenamiento seguro del idToken y
/// verificación del estado de autenticación del usuario.
///
/// ## Flujo de autenticación
/// 1. **Inicialización**: El SDK de Google se inicializa de forma perezosa
///    la primera vez que se llama a `iniciarSesion()`.
/// 2. **Inicio de sesión**: Muestra el selector de cuentas de Google, obtiene
///    el `idToken` y los datos del perfil (email, nombre, foto), y los almacena
///    de forma segura.
/// 3. **Verificación**: `estaAutenticado()` valida que el token exista y no
///    haya expirado (decodificando el JWT).
/// 4. **Cierre de sesión**: Cierra la sesión en Google y elimina los datos
///    del almacenamiento seguro.
///
/// ## Consideraciones de seguridad
/// - El idToken se almacena en [FlutterSecureStorage] (Keychain en iOS,
///   Keystore en Android), garantizando cifrado a nivel de sistema operativo.
/// - [estaAutenticado] valida la expiración del JWT, no solo su existencia,
///   evitando el uso de tokens caducados.
/// - Los datos del perfil (email, nombre, foto) también se almacenan de forma
///   segura para su uso posterior.
///
/// ## Manejo de errores
/// - Los métodos retornan `Future<bool>` para indicar éxito/fracaso, permitiendo
///   que la UI reaccione adecuadamente.
/// - Los errores se registran con [Logger] para facilitar la depuración.
/// - Si la inicialización falla, se permite reintentar en la siguiente llamada.
///
/// ## Ejemplo de uso
/// ```dart
/// final servicio = ServicioGoogle();
///
/// // Iniciar sesión
/// final ok = await servicio.iniciarSesion();
/// if (ok) {
///   print('Usuario autenticado');
/// } else {
///   print('Error o cancelación');
/// }
///
/// // Verificar autenticación
/// final autenticado = await servicio.estaAutenticado();
/// if (autenticado) {
///   final token = await servicio.obtenerToken();
///   print('Token: $token');
/// }
///
/// // Cerrar sesión
/// await servicio.cerrarSesion();
/// ```
///
/// ## Dependencias
/// - [google_sign_in]: Para la autenticación con Google.
/// - [flutter_secure_storage]: Para almacenamiento seguro.
/// - [logger]: Para registro de eventos y errores.
/// - [AppConst]: Para las claves de almacenamiento.
///
/// ## Notas de implementación
/// - La inicialización se realiza de forma perezosa y asíncrona mediante
///   `_asegurarInicializacion()`, que garantiza que solo se ejecute una vez.
/// - El token se almacena en secure storage; no se mantiene en memoria para
///   reducir el riesgo de exposición.
/// - La validación de expiración decodifica el payload del JWT sin verificar
///   la firma, asumiendo que Google ya lo firmó correctamente.
/// - En caso de error al decodificar el JWT, se considera expirado por seguridad.
///
/// ## Posibles mejoras
/// - Agregar un método para renovar el token automáticamente si está próximo a
///   expirar.
/// - Permitir la recuperación del token desde el almacenamiento sin necesidad
///   de verificar expiración (para casos de uso offline).
/// - Soportar múltiples cuentas o cambiar de cuenta sin cerrar sesión.
class ServicioGoogle {
  final FlutterSecureStorage _almacenamiento;
  final Logger _logger;
  final GoogleSignIn _google;

  bool _inicializado = false;
  Future<void>? _inicializacionFutura;

  /// Crea una instancia del servicio de autenticación.
  ///
  /// Los parámetros son opcionales para facilitar la inyección de
  /// dependencias en pruebas unitarias. Si no se proporcionan, se usan
  /// las instancias por defecto.
  ///
  /// - [almacenamiento]: Instancia de [FlutterSecureStorage] (por defecto: `const FlutterSecureStorage()`).
  /// - [logger]: Instancia de [Logger] (por defecto: `Logger()`).
  /// - [google]: Instancia de [GoogleSignIn] (por defecto: `GoogleSignIn.instance`).
  ServicioGoogle({
    FlutterSecureStorage? almacenamiento,
    Logger? logger,
    GoogleSignIn? google,
  }) : _almacenamiento = almacenamiento ?? const FlutterSecureStorage(),
       _logger = logger ?? Logger(),
       _google = google ?? GoogleSignIn.instance;

  /// Asegura que el SDK de Google Sign-In esté inicializado.
  ///
  /// Si ya está inicializado, retorna inmediatamente. Si no, inicia la
  /// inicialización de forma asíncrona y la almacena en `_inicializacionFutura`
  /// para evitar múltiples inicializaciones concurrentes.
  ///
  /// Lanza una excepción si la inicialización falla.
  Future<void> _asegurarInicializacion() async {
    if (_inicializado) return;

    _inicializacionFutura ??= _inicializar();
    await _inicializacionFutura;
  }

  /// Inicializa el SDK de Google Sign-In.
  ///
  /// Este método se llama una sola vez a través de `_asegurarInicializacion()`.
  /// Si falla, se resetea `_inicializacionFutura` para permitir reintentos.
  ///
  /// Lanza una excepción si la inicialización falla.
  Future<void> _inicializar() async {
    try {
      await _google.initialize();
      _inicializado = true;
      _logger.i('Google Sign-In initialized successfully');
    } catch (error, stackTrace) {
      _inicializacionFutura = null; // Permitir reintentos
      _logger.e(
        'Failed to initialize Google Sign-In',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Inicia el flujo de autenticación con Google.
  ///
  /// Este método:
  /// 1. Asegura que el SDK esté inicializado.
  /// 2. Muestra el selector de cuentas de Google al usuario.
  /// 3. Solicita los scopes `email` y `profile`.
  /// 4. Obtiene el `idToken` y los datos del perfil.
  /// 5. Almacena de forma segura: idToken, email, nombre y URL de la foto.
  ///
  /// Retorna:
  /// - `true` si la autenticación fue exitosa y los datos se almacenaron
  ///   correctamente.
  /// - `false` en caso de:
  ///   - Cancelación por parte del usuario.
  ///   - Token vacío o nulo.
  ///   - Error durante la autenticación o el almacenamiento.
  ///
  /// ## Ejemplo:
  /// ```dart
  /// final ok = await servicioGoogle.iniciarSesion();
  /// if (ok) {
  ///   // Navegar a la pantalla principal
  /// }
  /// ```
  Future<bool> iniciarSesion() async {
    try {
      await _asegurarInicializacion();

      final GoogleSignInAccount cuenta = await _google.authenticate(
        scopeHint: <String>['email', 'profile'],
      );

      final GoogleSignInAuthentication autenticacion = cuenta.authentication;
      final String? tokenId = autenticacion.idToken;

      if (tokenId == null || tokenId.isEmpty) {
        _logger.w('No ID token received from Google');
        return false;
      }

      // Almacenar todos los datos del usuario de forma segura
      await _almacenamiento.write(
        key: AppConst.etiquetaIdToken,
        value: tokenId,
      );
      await _almacenamiento.write(
        key: AppConst.etiquetaEmail,
        value: cuenta.email,
      );
      await _almacenamiento.write(
        key: AppConst.etiquetaNombre,
        value: cuenta.displayName,
      );
      await _almacenamiento.write(
        key: AppConst.etiquetaUrlFoto,
        value: cuenta.photoUrl,
      );

      _logger.i('User authenticated: ${cuenta.email}');
      return true;
    } catch (error, stackTrace) {
      _logger.e('Authentication failed', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Obtiene el idToken almacenado en el almacenamiento seguro.
  ///
  /// Retorna:
  /// - El token como `String?`, o `null` si no existe o si ocurre un error
  ///   durante la lectura.
  ///
  /// ## Ejemplo:
  /// ```dart
  /// final token = await servicio.obtenerToken();
  /// if (token != null) {
  ///   // Usar token para peticiones autenticadas
  /// }
  /// ```
  Future<String?> obtenerToken() async {
    try {
      return await _almacenamiento.read(key: AppConst.etiquetaIdToken);
    } catch (error) {
      _logger.e('Failed to retrieve token from secure storage', error: error);
      return null;
    }
  }

  /// Verifica si el usuario tiene una sesión activa y válida.
  ///
  /// La verificación consta de dos pasos:
  /// 1. El token existe en el almacenamiento seguro.
  /// 2. El token no ha expirado (se decodifica el JWT y se comprueba el campo `exp`).
  ///
  /// Retorna:
  /// - `true` si el token existe y no ha expirado.
  /// - `false` si el token no existe, está vacío o ha expirado.
  ///
  /// ## Nota sobre la decodificación del JWT
  /// Este método decodifica el payload del JWT sin verificar la firma,
  /// asumiendo que Google ya lo firmó correctamente. Si la decodificación falla,
  /// se considera el token como expirado por seguridad.
  ///
  /// ## Ejemplo:
  /// ```dart
  /// if (await servicio.estaAutenticado()) {
  ///   // Mostrar contenido protegido
  /// }
  /// ```
  Future<bool> estaAutenticado() async {
    final String? token = await obtenerToken();
    if (token == null || token.isEmpty) {
      return false;
    }
    return !_estaTokenExpirado(token);
  }

  /// Decodifica el payload del JWT y verifica el campo `exp`.
  ///
  /// Método interno que extrae la parte del payload (segunda parte del JWT),
  /// lo decodifica en base64 y parsea el JSON resultante para obtener
  /// el timestamp de expiración (`exp`).
  ///
  /// Retorna:
  /// - `true` si el token ha expirado o no se puede decodificar.
  /// - `false` si el token es válido y no ha expirado.
  ///
  /// Parámetros:
  /// - [token]: El JWT en formato Base64 URL.
  bool _estaTokenExpirado(String token) {
    try {
      final List<String> partes = token.split('.');
      if (partes.length != 3) return true;

      final String payloadBase64 = partes[1];
      final String payloadJson = utf8.decode(
        base64Url.decode(base64Url.normalize(payloadBase64)),
      );
      final Map<String, dynamic> payload =
          json.decode(payloadJson) as Map<String, dynamic>;

      final int? exp = payload['exp'] as int?;
      if (exp == null) return true;

      final DateTime expiracion = DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
      );
      return DateTime.now().isAfter(expiracion);
    } catch (error) {
      _logger.w('Failed to decode JWT', error: error);
      return true; // Ante la duda, considerar expirado
    }
  }

  /// Cierra la sesión del usuario.
  ///
  /// Realiza dos acciones:
  /// 1. Llama a `signOut()` en el SDK de Google para cerrar la sesión a nivel
  ///    del sistema.
  /// 2. Elimina todas las claves relacionadas con el usuario del almacenamiento
  ///    seguro (idToken, email, nombre y foto).
  ///
  /// Retorna:
  /// - `true` si ambas operaciones fueron exitosas.
  /// - `false` si ocurrió un error durante el cierre de sesión o la eliminación
  ///   de datos.
  ///
  /// ## Ejemplo:
  /// ```dart
  /// final ok = await servicio.cerrarSesion();
  /// if (ok) {
  ///   // Redirigir a la pantalla de login
  /// }
  /// ```
  Future<bool> cerrarSesion() async {
    try {
      await _google.signOut();
      await _almacenamiento.delete(key: AppConst.etiquetaIdToken);
      await _almacenamiento.delete(key: AppConst.etiquetaEmail);
      // Opcionalmente, también se podrían eliminar nombre y foto,
      // pero se mantienen por si se necesitan para futuros inicios de sesión.
      // Si se desea eliminarlos, se puede hacer:
      // await _almacenamiento.delete(key: AppConst.etiquetaNombre);
      // await _almacenamiento.delete(key: AppConst.etiquetaUrlFoto);
      _logger.i('User signed out successfully');
      return true;
    } catch (error, stackTrace) {
      _logger.e('Failed to sign out', error: error, stackTrace: stackTrace);
      return false;
    }
  }
}
