import 'package:flutter/material.dart';
import 'package:weather/model/coordenada.dart';
import 'package:weather/model/observacion_meteo.dart';
import 'package:weather/model/farmacia.dart';
import 'package:weather/services/servicio_google.dart';
import 'package:weather/services/servicio_rest.dart';
import 'package:weather/services/servicio_ubicacion.dart';

/// Controlador principal de la app usando el patrón Provider.
/// Maneja la comunicación entre la API, el GPS y lo que se muestra en pantalla.
class WeatherScreenController extends ChangeNotifier {
  final ServicioRest servicioRest;
  final ServicioUbicacion servicioUbicacion;
  final ServicioGoogle servicioGoogle;

  bool _estaCargando = false;
  String? _mensajeError;
  Coordenada? _coordenadaActual;
  ObservacionMeteo? _observacionMeteo;
  List<Farmacia>? _farmacias;

  bool get estaCargando => _estaCargando;
  String? get mensajeError => _mensajeError;
  Coordenada? get coordenadaActual => _coordenadaActual;
  ObservacionMeteo? get observacionMeteo => _observacionMeteo;
  List<Farmacia>? get farmacias => _farmacias;
  bool get tieneDatos => _coordenadaActual != null && _observacionMeteo != null;

  WeatherScreenController({
    required this.servicioRest,
    required this.servicioUbicacion,
    required this.servicioGoogle,
  });

  /// Método principal que carga toda la información necesaria.
  /// Obtiene la ubicación actual y luego consulta el clima y las farmacias.
  /// Utiliza bloques try-catch para manejar errores de conexión sin que la app colapse
  Future<void> inicializarDatos() async {
    _estaCargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final String? token = await servicioGoogle.obtenerToken();
      if (token == null || token.isEmpty) throw Exception('Sesión inválida.');

      _coordenadaActual = await servicioUbicacion.obtenerUbicacionActual();

      _observacionMeteo = await servicioRest.obtenerObservacionCercana(
        idToken: token,
        latitud: _coordenadaActual!.latitud,
        longitud: _coordenadaActual!.longitud,
      );

      try {
        _farmacias = await servicioRest.obtenerFarmacias(
          idToken: token,
          latitud: _coordenadaActual!.latitud,
          longitud: _coordenadaActual!.longitud,
        );
      } catch (e) {
        _farmacias = [];
      }
    } catch (error) {
      _mensajeError = 'Error al conectar con el servidor.';
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  /// Permite volver a intentar la conexión si el usuario presiona el botón de error.
  Future<void> reintentar() async {
    _estaCargando = true;
    _mensajeError = null;
    notifyListeners();
    try {
      await servicioGoogle.cerrarSesion();
      await servicioGoogle.iniciarSesion();
      await inicializarDatos();
    } catch (e) {
      _estaCargando = false;
      _mensajeError = 'Fallo de red. Presiona "Cerrar Sesión".';
      notifyListeners();
    }
  }
}
