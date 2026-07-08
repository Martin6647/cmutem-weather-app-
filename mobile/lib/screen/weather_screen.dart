import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:weather/consts/app_colors.dart';
import 'package:weather/controller/weather_screen_controller.dart';
import 'package:weather/model/coordenada.dart';
import 'package:weather/model/observacion_meteo.dart';
import 'package:weather/widgets/my_menu.dart';

/// Pantalla principal de monitoreo meteorológico.
///
/// Muestra un mapa con la ubicación actual del usuario y los indicadores
/// climáticos obtenidos del servidor. Maneja estados de carga, error y
/// datos exitosos mediante el patrón Consumer de Provider.
///
/// Flujo de visualización:
/// 1. Estado de carga: Muestra indicador de progreso circular.
/// 2. Estado de error: Muestra mensaje de error con botón de reintentar.
/// 3. Estado exitoso: Muestra mapa y datos climáticos.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();

    // Ejecutar inicialización después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherScreenController>().inicializarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo Meteorológico'),
        centerTitle: true,
      ),
      drawer: MyMenu(),
      body: Consumer<WeatherScreenController>(
        builder:
            (
              BuildContext context,
              WeatherScreenController controlador,
              Widget? child,
            ) {
              // Estado de carga
              if (controlador.estaCargando) {
                return _construirEstadoCarga();
              }

              // Estado de error
              if (controlador.mensajeError != null) {
                return _construirEstadoError(
                  controlador.mensajeError!,
                  controlador.reintentar,
                );
              }

              // Estado exitoso - validar que hay datos
              if (!controlador.tieneDatos) {
                return _construirEstadoVacio();
              }

              // Estado exitoso con datos
              return Column(
                children: <Widget>[
                  Expanded(flex: 1, child: _construirSeccionMapa(controlador)),
                  const Divider(
                    height: 1,
                    thickness: 2.0,
                    color: AppColors.naranjaPrimario,
                  ),
                  Expanded(flex: 1, child: _construirSeccionClima(controlador)),
                ],
              );
            },
      ),
    );
  }

  /// Construye el widget de estado de carga.
  ///
  /// Muestra un indicador de progreso circular centrado en la pantalla.
  Widget _construirEstadoCarga() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16.0),
          Text(
            'Cargando datos meteorológicos...',
            style: TextStyle(fontSize: 16.0, color: AppColors.gris),
          ),
        ],
      ),
    );
  }

  /// Construye el widget de estado de error.
  ///
  /// [mensaje] Texto descriptivo del error ocurrido.
  /// [onReintentar] Función callback para reintentar la carga.
  Widget _construirEstadoError(String mensaje, VoidCallback onReintentar) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 64.0, color: AppColors.rojo),
            const SizedBox(height: 16.0),
            Text(
              mensaje,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: AppColors.rojo,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el widget de estado vacío.
  ///
  /// Se muestra cuando no hay datos disponibles después de la carga.
  Widget _construirEstadoVacio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.cloud_off, size: 64.0, color: AppColors.gris),
          SizedBox(height: 16.0),
          Text(
            'No hay datos meteorológicos disponibles',
            style: TextStyle(fontSize: 16.0, color: AppColors.gris),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construye la sección del mapa con la ubicación actual.
  ///
  /// [controlador] Controlador que contiene la coordenada actual.
  /// Asume que [controlador.coordenadaActual] no es null.
  Widget _construirSeccionMapa(WeatherScreenController controlador) {
    final Coordenada coordenada = controlador.coordenadaActual!;
    final LatLng puntoCentral = LatLng(coordenada.latitud, coordenada.longitud);

    return FlutterMap(
      options: MapOptions(initialCenter: puntoCentral, initialZoom: 15.0),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.weather',
        ),
        MarkerLayer(
          markers: <Marker>[
            Marker(
              point: puntoCentral,
              width: 40.0,
              height: 40.0,
              child: const Icon(
                Icons.location_pin,
                color: AppColors.rojo,
                size: 40.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye una fila con etiqueta y valor para los datos climáticos.
  ///
  /// [etiqueta] Texto descriptivo del indicador (ej: "Temperatura").
  /// [valor] Valor formateado del indicador (ej: "18.5 ºC").
  Widget _construirFilaClima(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            etiqueta,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16.0,
              color: AppColors.azulAcentuado,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de indicadores climáticos.
  ///
  /// [controlador] Controlador que contiene la observación meteorológica.
  /// Asume que [controlador.observacionMeteo] no es null.
  Widget _construirSeccionClima(WeatherScreenController controlador) {
    final ObservacionMeteo clima = controlador.observacionMeteo!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Indicadores Climáticos Actuales',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          _construirFilaClima('ID Observación', clima.idObservacion.toString()),
          _construirFilaClima(
            'Temperatura',
            '${clima.temperatura.toStringAsFixed(1)} ºC',
          ),
          _construirFilaClima('Humedad', '${clima.humedad.toString()}%'),
          _construirFilaClima('UV', '${clima.ultravioleta}'),
        ],
      ),
    );
  }
}
