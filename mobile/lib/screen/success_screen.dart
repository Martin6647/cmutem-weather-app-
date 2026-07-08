import 'package:flutter/material.dart';
import 'package:weather/consts/app_colors.dart';
import 'package:weather/screen/login_screen.dart';
import 'package:weather/services/servicio_google.dart';
import 'package:weather/widgets/my_menu.dart';

/// Pantalla que se muestra después de una autenticación exitosa con Google.
///
/// Esta pantalla confirma el inicio de sesión correcto, mostrando un mensaje
/// de bienvenida y un icono de verificación. Incluye una barra de aplicación
/// con título y un menú lateral ([MyMenu]) que proporciona opciones adicionales
/// de navegación o configuración.
///
/// ## Estructura visual
/// - **AppBar**: Barra superior con el título "Autenticación Exitosa" centrado.
/// - **Drawer**: Menú lateral personalizado ([MyMenu]) para navegación.
/// - **Fondo**: Gradiente radial con centro superior izquierdo, usando
///   [AppColors.blancoClaro] y transparente para dar un efecto de luz.
/// - **Icono**: `Icons.check_circle` de gran tamaño (120 px) con sombra,
///   representando el éxito de la operación.
/// - **Mensajes**: Título "¡Bienvenido!" y subtítulo "Autenticación exitosa"
///   con estilo adecuado y color blanco semi-transparente para el subtítulo.
///
/// ## Comportamiento
/// Esta pantalla es puramente informativa y no incluye lógica de cierre de
/// sesión. El cierre de sesión y otras acciones se delegan al menú lateral
/// [MyMenu], que puede contener opciones como "Cerrar sesión" o "Configuración".
///
/// ## Dependencias
/// - [AppColors]: Paleta de colores centralizada.
/// - [MyMenu]: Widget del menú lateral que provee navegación adicional.
/// - [ServicioGoogle]: Servicio de autenticación (aunque no se usa directamente
///   en esta pantalla, se mantiene como instancia privada para futuras
///   extensiones).
///
/// ## Ejemplo de uso
/// ```dart
/// // Navegar a la pantalla de éxito después de un login exitoso
/// Navigator.pushReplacement(
///   context,
///   MaterialPageRoute(builder: (context) => const SuccessScreen()),
/// );
/// ```
///
/// ## Notas de diseño
/// - El fondo utiliza un gradiente radial en lugar de lineal para dar un efecto
///   de luz más suave y moderno.
/// - El icono de éxito incluye una sombra para resaltar su importancia.
/// - El contenido está centrado vertical y horizontalmente, envuelto en
///   [SingleChildScrollView] para soportar pantallas pequeñas.
/// - El color del subtítulo ([AppColors.blancoClarisimo]) asegura legibilidad
///   sobre el fondo claro.
///
/// ## Consideraciones de implementación
/// - La clase crea una instancia de [ServicioGoogle] (`_servicioGoogle`) aunque
///   no se utiliza en la UI actual. Esta instancia podría emplearse en el
///   futuro para implementar el cierre de sesión directamente desde esta
///   pantalla, pero por ahora se delega al menú.
/// - El widget [MyMenu] debe estar correctamente implementado para proporcionar
///   las opciones de navegación esperadas.
///
/// ## Mejoras potenciales
/// - Mostrar datos reales del usuario (nombre, email, foto de perfil) en lugar
///   del subtítulo genérico.
/// - Agregar un botón "Continuar" para navegar a la pantalla principal de la
///   aplicación.
/// - Implementar el cierre de sesión directamente en esta pantalla con un
///   botón, en lugar de depender únicamente del menú lateral.
class SuccessScreen extends StatelessWidget {
  /// Instancia del servicio de Google para manejar el cierre de sesión.
  ///
  /// Se crea directamente en la clase; en un entorno con inyección de
  /// dependencias, podría recibirse como parámetro. Actualmente no se usa
  /// en la UI, pero se mantiene para futuras extensiones.
  final ServicioGoogle _servicioGoogle = ServicioGoogle();

  /// Constructor de la pantalla de éxito.
  ///
  /// No recibe parámetros, ya que la información de usuario se obtiene
  /// típicamente de otras fuentes (servicio, almacenamiento local).
  SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autenticación Exitosa'),
        centerTitle: true,
      ),
      drawer: MyMenu(),
      body: Container(
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
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),
                            // Icono de éxito con sombra
                            Icon(
                              Icons.check_circle,
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
                              '¡Bienvenido!',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(height: 16),
                            // Subtítulo descriptivo
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                'Autenticación exitosa',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.blancoClarisimo,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
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
