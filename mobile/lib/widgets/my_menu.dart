import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:weather/controller/weather_screen_controller.dart';
import 'package:weather/screen/login_screen.dart';
import 'package:weather/screen/success_screen.dart';
import 'package:weather/screen/weather_screen.dart';
import 'package:weather/services/servicio_almacenamiento.dart';
import 'package:weather/services/servicio_google.dart';
import 'package:weather/services/servicio_rest.dart';
import 'package:weather/services/servicio_ubicacion.dart';

class MyMenu extends StatelessWidget {
  static final Logger _logger = Logger();

  const MyMenu({super.key});

  /// Maneja el cierre de sesión del usuario.
  ///
  /// Este método asíncrono:
  /// 1. Llama a `_servicioGoogle.cerrarSesion()` para finalizar la sesión.
  /// 2. Comprueba que el contexto siga montado (evita navegación en widgets
  ///    destruidos).
  /// 3. Navega a la [LoginScreen] reemplazando la pila actual.
  ///
  /// [context]: El contexto de construcción del widget, necesario para
  ///            la navegación y para verificar `mounted`.
  Future<void> _manejarCierreSesion(BuildContext context) async {
    ServicioGoogle servicioGoogle = ServicioGoogle();
    await servicioGoogle.cerrarSesion();
    // Verificar que el widget aún esté en el árbol antes de navegar
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: FutureBuilder<String>(
              future: ServicioAlmacenamiento.obtenerNombre(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(snapshot.data ?? '');
                } else if (snapshot.hasError) {
                  return const Text("Nombre");
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            accountEmail: FutureBuilder<String>(
              future: ServicioAlmacenamiento.obtenerEmail(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(snapshot.data ?? '');
                } else if (snapshot.hasError) {
                  return const Text("usuario@correo.cl");
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: FutureBuilder(
                  future: ServicioAlmacenamiento.obtenerUrlFoto(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      String url = snapshot.data ?? '';
                      if (url.isNotEmpty) {
                        return CachedNetworkImage(
                          imageUrl: url,
                          placeholder: (context, url) {
                            return const CircularProgressIndicator();
                          },
                          errorWidget: (context, url, error) {
                            _logger.e(error);
                            return const Icon(
                              Icons.person_3,
                              color: Colors.red,
                              size: 47,
                            );
                          },
                        );
                      } else {
                        return const Icon(Icons.person_4);
                      }
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.person);
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SuccessScreen();
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Ubicación'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Provider<ServicioRest>(
                      create: (_) => ServicioRest(),
                      child: Provider<ServicioUbicacion>(
                        create: (_) => ServicioUbicacion(),
                        child: Provider<ServicioGoogle>(
                          create: (_) => ServicioGoogle(),
                          child: ChangeNotifierProvider<WeatherScreenController>(
                            create: (BuildContext context) =>
                                WeatherScreenController(
                                  servicioRest: context.read<ServicioRest>(),
                                  servicioUbicacion:
                                      context.read<ServicioUbicacion>(),
                                  servicioGoogle: context.read<ServicioGoogle>(),
                                ),
                            child: const WeatherScreen(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              _manejarCierreSesion(context);
            },
          ),
        ],
      ),
    );
  }
}
