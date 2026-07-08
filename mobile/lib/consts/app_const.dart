/// Clase utilitaria que almacena las claves (etiquetas) utilizadas para
/// guardar y recuperar datos del usuario en el almacenamiento persistente
/// (por ejemplo, [SharedPreferences]).
///
/// Estas constantes definen los nombres de las claves para identificar de forma
/// única cada dato relacionado con la sesión del usuario, evitando errores de
/// escritura y facilitando el mantenimiento.
///
/// ## Propósito
/// Centralizar las claves de almacenamiento permite:
/// - Evitar la duplicación de cadenas literales en el código.
/// - Facilitar cambios en los nombres de las claves (solo se modifica aquí).
/// - Mejorar la legibilidad y el autocompletado en el IDE.
///
/// ## Claves definidas
/// - [etiquetaIdToken]: Token de autenticación del usuario.
/// - [etiquetaEmail]: Correo electrónico del usuario.
/// - [etiquetaNombre]: Nombre completo o de usuario.
/// - [etiquetaUrlFoto]: URL de la foto de perfil del usuario.
///
/// ## Ejemplo de uso
/// ```dart
/// import 'package:shared_preferences/shared_preferences.dart';
///
/// // Guardar datos del usuario
/// Future<void> guardarDatosUsuario(String token, String email) async {
///   final prefs = await SharedPreferences.getInstance();
///   await prefs.setString(AppConst.etiquetaIdToken, token);
///   await prefs.setString(AppConst.etiquetaEmail, email);
/// }
///
/// // Recuperar datos del usuario
/// Future<Map<String, String?>> obtenerDatosUsuario() async {
///   final prefs = await SharedPreferences.getInstance();
///   return {
///     'token': prefs.getString(AppConst.etiquetaIdToken),
///     'email': prefs.getString(AppConst.etiquetaEmail),
///     'nombre': prefs.getString(AppConst.etiquetaNombre),
///     'foto': prefs.getString(AppConst.etiquetaUrlFoto),
///   };
/// }
/// ```
///
/// ## Notas
/// - Todas las constantes son `static const String`, por lo que se acceden
///   directamente desde la clase sin necesidad de instanciarla.
/// - El uso de `const` garantiza que los valores sean inmutables y se
///   optimicen en tiempo de compilación, mejorando el rendimiento.
/// - Se recomienda usar estas constantes en lugar de cadenas literales para
///   evitar errores tipográficos y facilitar futuros cambios.
class AppConst {
  /// Clave para almacenar el token de identificación (ID token) del usuario.
  ///
  /// Este token se utiliza para autenticar solicitudes al servidor y mantener
  /// la sesión activa. Ejemplo: `'idToken'`.
  static const String etiquetaIdToken = "idToken";

  /// Clave para almacenar el correo electrónico del usuario autenticado.
  ///
  /// Se usa para mostrar el email en la interfaz o para recuperación de cuenta.
  /// Ejemplo: `'email'`.
  static const String etiquetaEmail = "email";

  /// Clave para almacenar el nombre del usuario (puede ser nombre completo
  /// o nombre de usuario).
  ///
  /// Se utiliza para personalizar saludos y mostrar información del perfil.
  /// Ejemplo: `'name'`.
  static const String etiquetaNombre = "name";

  /// Clave para almacenar la URL de la foto de perfil del usuario.
  ///
  /// Esta URL apunta a la imagen de avatar del usuario, que puede cargarse
  /// con widgets como [Image.network]. Ejemplo: `'photoUrl'`.
  static const String etiquetaUrlFoto = "photoUrl";
}
