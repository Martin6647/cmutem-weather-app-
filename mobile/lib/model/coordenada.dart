/// Representa un punto geográfico en la superficie terrestre mediante
/// coordenadas de latitud y longitud.
///
/// Esta clase se utiliza en toda la aplicación para almacenar y transmitir
/// la ubicación del dispositivo y realizar consultas meteorológicas cercanas.
/// Al ser una clase con constructor `const`, sus instancias son inmutables
/// y pueden ser reutilizadas en múltiples contextos sin riesgo de modificación.
///
/// ## Rangos típicos
/// - **Latitud**: Valores entre -90.0 (Polo Sur) y 90.0 (Polo Norte).
/// - **Longitud**: Valores entre -180.0 (Oeste) y 180.0 (Este).
///
/// ## Ejemplo de uso
/// ```dart
/// final ubicacion = Coordenada(latitud: 40.7128, longitud: -74.0060);
/// print('Latitud: ${ubicacion.latitud}, Longitud: ${ubicacion.longitud}');
/// ```
///
/// ## Validación
/// Aunque esta clase no valida los valores en el constructor, se recomienda
/// verificar que estén dentro de los rangos aceptables antes de usarlos,
/// especialmente si provienen de fuentes externas.
///
/// ## Nota sobre inmutabilidad
/// Todos los campos son `final`, y el constructor es `const`, lo que permite
/// crear constantes de compilación y asegura que los objetos sean inmutables.
class Coordenada {
  /// Latitud del punto, en grados decimales.
  ///
  /// Los valores positivos indican el hemisferio norte, los negativos el sur.
  final double latitud;

  /// Longitud del punto, en grados decimales.
  ///
  /// Los valores positivos indican el este, los negativos el oeste.
  final double longitud;

  /// Crea una nueva instancia de [Coordenada] con la latitud y longitud dadas.
  ///
  /// Ambos parámetros son obligatorios.
  ///
  /// ## Ejemplo:
  /// ```dart
  /// final coord = Coordenada(latitud: 41.3851, longitud: 2.1734);
  /// ```
  const Coordenada({required this.latitud, required this.longitud});
}
