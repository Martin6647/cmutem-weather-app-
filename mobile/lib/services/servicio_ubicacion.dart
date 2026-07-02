import 'package:geolocator/geolocator.dart';
import 'package:weather/model/coordenada.dart';

class ServicioUbicacion {
  Future<Coordenada> obtenerUbicacionActual() async {
    final bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      throw Exception('Los servicios de ubicación están deshabilitados');
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.deniedForever) {
      throw Exception('Permisos de ubicación denegados permanentemente');
    }

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw Exception('Permisos de ubicación denegados por el usuario');
      }
    }

    final Position posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
    );

    return Coordenada(latitud: posicion.latitude, longitud: posicion.longitude);
  }
}
