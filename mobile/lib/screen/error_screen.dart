import 'package:flutter/material.dart';
import 'package:weather/consts/app_colors.dart';
import 'package:weather/screen/login_screen.dart';

/// Pantalla de error que se muestra cuando ocurre un fallo durante el inicio de sesión
/// u otra operación crítica.
///
/// Esta pantalla proporciona una interfaz amigable y atractiva para informar al usuario
/// sobre un error, mostrando un mensaje descriptivo y un botón para volver a la pantalla
/// de inicio de sesión. Utiliza un degradado de colores naranjas como fondo, con un
/// efecto radial sutil, y un icono grande de "cancelar" para enfatizar el estado de error.
///
/// ## Estructura visual
/// - **Fondo**: Degradado lineal de naranja (desde [AppColors.naranjaPrimarioClaro]
///   hasta [AppColors.naranjaPrimarioOscuro]) con un toque radial blanco para dar
///   profundidad y un efecto de luz.
/// - **Icono**: Icono `Icons.cancel` de gran tamaño (120 px) con sombra,
///   indicando claramente el estado de error.
/// - **Mensaje**: Título "¡Error!" en un estilo de texto grande y un mensaje
///   descriptivo (personalizable) con color blanco semi-transparente.
/// - **Botón**: Botón "Volver" con estilo elevado (fondo blanco, texto naranja)
///   que redirige a [LoginScreen].
///
/// ## Parámetros
/// - [mensajeError]: Texto opcional que describe el error. Si es `null`, se muestra
///   un mensaje genérico: "Error al iniciar sesión con Google". Útil para
///   personalizar el mensaje según el tipo de fallo.
///
/// ## Comportamiento
/// Al presionar el botón "Volver", la navegación reemplaza la pila actual con
/// [LoginScreen] usando [Navigator.pushReplacement]. Esto evita que el usuario
/// pueda regresar a esta pantalla de error con el botón "atrás" del sistema,
/// asegurando una experiencia de navegación limpia.
///
/// ## Ejemplo de uso
/// ```dart
/// // Mostrar error con mensaje personalizado
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => ErrorScreen(
///       mensajeError: 'No se pudo conectar con el servidor.',
///     ),
///   ),
/// );
///
/// // Mostrar error con mensaje por defecto
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const ErrorScreen(),
///   ),
/// );
///
/// // También se puede usar con pushReplacement si se quiere reemplazar
/// // la pantalla actual por la de error
/// Navigator.pushReplacement(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const ErrorScreen(),
///   ),
/// );
/// ```
///
/// ## Notas de diseño
/// - Los colores utilizados provienen de [AppColors], lo que garantiza consistencia
///   con la paleta de la aplicación y facilita futuros cambios.
/// - El widget está envuelto en [SafeArea] para respetar las áreas seguras del
///   dispositivo (como la muesca o la barra de estado).
/// - El contenido está dentro de un [SingleChildScrollView] para soportar pantallas
///   pequeñas y orientaciones verticales, aunque el contenido es centrado.
/// - El botón "Volver" tiene un estilo elevado y redondeado (radio 12) que
///   se mantiene coherente con la identidad visual de la app.
/// - El icono grande de error incluye una sombra para darle profundidad y
///   resaltar su importancia.
///
/// ## Posibles mejoras
/// - Agregar un [AppBar] opcional para integrarse con la navegación estándar
///   y permitir un cierre manual en lugar de solo el botón.
/// - Incluir un indicador de carga o reintento automático en futuras versiones,
///   como un botón "Reintentar" que intente la operación nuevamente.
/// - Extraer el botón a un widget reutilizable para mantener el código limpio
///   y facilitar su uso en otras pantallas de error.
/// - Considerar el soporte para temas oscuros/claros adaptando los colores
///   según el tema del sistema, aunque actualmente usa colores fijos.
class ErrorScreen extends StatelessWidget {
  /// Mensaje de error personalizado que se muestra al usuario.
  ///
  /// Si es `null`, se utiliza el mensaje por defecto: "Error al iniciar sesión con Google".
  /// Este mensaje se muestra en un texto centrado con color blanco semi-transparente
  /// ([AppColors.blancoClarisimo]).
  final String? mensajeError;

  /// Constructor de la pantalla de error.
  ///
  /// [mensajeError] es opcional y permite personalizar el texto mostrado.
  /// La [key] se pasa al superconstructor para identificar el widget.
  const ErrorScreen({this.mensajeError, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.42, -0.91),
            end: Alignment(-0.42, 0.91),
            colors: [
              AppColors.naranjaPrimarioClaro,
              AppColors.naranjaPrimario,
              AppColors.naranjaPrimarioMedio,
              AppColors.naranjaPrimarioOscuro,
            ],
            stops: [0.0, 0.25, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Efecto de luz radial para dar profundidad al fondo
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.2, 0.5),
                  radius: 0.8,
                  colors: [AppColors.blancoClaro, Colors.transparent],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          // Icono grande de error con sombra
                          Icon(
                            Icons.cancel,
                            size: 120,
                            color: AppColors.blanco,
                            shadows: [
                              BoxShadow(
                                color: AppColors.negroClaro,
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Título principal
                          Text(
                            '¡Error!',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const SizedBox(height: 16),
                          // Mensaje descriptivo
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              mensajeError ??
                                  'Error al iniciar sesión con Google',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.blancoClarisimo),
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Botón para volver a la pantalla de inicio de sesión
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blanco,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  // Reemplaza la pila de navegación para evitar regresar a esta pantalla
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Volver',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppColors.naranjaPrimario,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
