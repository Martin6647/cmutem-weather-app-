import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:weather/consts/app_colors.dart';
import 'package:weather/controller/weather_screen_controller.dart';
import 'package:weather/model/coordenada.dart';
import 'package:weather/model/observacion_meteo.dart';
import 'package:weather/model/farmacia.dart';
import 'package:weather/widgets/my_menu.dart';

/// ## WeatherScreen
/// Pantalla principal de la aplicación de monitoreo meteorológico.
///
/// **Patrón Arquitectónico**: Implementa el patrón MVA (Model-View-Architecture)
/// mediante Provider, delegando toda la lógica de negocio al controlador centralizado.
///
/// **Gestión de Estado**: Utiliza [Consumer<WeatherScreenController>] para reactividad
/// declarativa, garantizando que solo los widgets observadores se reconstruyan
/// en respuesta a cambios de estado del modelo.
///
/// **Principios de Diseño**:
/// - **Separación de Responsabilidades**: La vista solo renderiza; la lógica reside
///   exclusivamente en [WeatherScreenController].
/// - **Inmutabilidad**: Extiende [StatelessWidget] para asegurar comportamiento predecible
///   y facilitar la depuración en ciclos de vida complejos.
/// - **Manejo de Estados**: Implementa transiciones de estado explícitas:
///   Cargando → Error → Vacío → Datos Válidos
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: const Text(
          'Panel de Monitoreo',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.principal,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.my_location_rounded,
              color: AppColors.acentoVibrante,
            ),
            tooltip: 'Actualizar mi ubicación',
            onPressed: () {
              context.read<WeatherScreenController>().inicializarDatos();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Actualizando ubicación...')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const MyMenu(),
      body: Consumer<WeatherScreenController>(
        builder: (context, controlador, child) {
          if (controlador.estaCargando) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.acentoVibrante),
            );
          }

          if (controlador.mensajeError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.rojo.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_off_rounded,
                        size: 64,
                        color: AppColors.rojo,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sin Cobertura API',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.principal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No hay datos de clima o farmacias para esta ubicación geográfica.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.gris, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => controlador.reintentar(),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Intentar nuevamente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.acentoVibrante,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!controlador.tieneDatos) {
            return const Center(child: Text('Sin datos'));
          }

          bool esVertical =
              MediaQuery.of(context).orientation == Orientation.portrait;

          return SingleChildScrollView(
            child: SafeArea(
              bottom: true,
              child: Column(
                children: [
                  SizedBox(
                    height: esVertical
                        ? MediaQuery.of(context).size.height * 0.4
                        : 160,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      child: Stack(
                        children: [
                          _construirSeccionMapa(context, controlador),
                          IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.principal.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 20.0,
                      bottom: 40.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirSeccionClima(controlador, esVertical),
                        const SizedBox(height: 24.0),
                        _construirSeccionFarmacias(context, controlador),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _construirSeccionMapa(
    BuildContext context,
    WeatherScreenController controlador,
  ) {
    final Coordenada coordenada = controlador.coordenadaActual!;
    LatLng puntoCentral = LatLng(coordenada.latitud, coordenada.longitud);

    List<Marker> marcadores = [
      Marker(
        point: puntoCentral,
        width: 60.0,
        height: 60.0,
        child: const Icon(
          Icons.person_pin_circle_rounded,
          color: AppColors.acentoVibrante,
          size: 50.0,
        ),
      ),
    ];

    if (controlador.farmacias != null && controlador.farmacias!.isNotEmpty) {
      for (var farmacia in controlador.farmacias!) {
        if (farmacia.latitud != null && farmacia.longitud != null) {
          marcadores.add(
            Marker(
              point: LatLng(farmacia.latitud!, farmacia.longitud!),
              width: 50.0,
              height: 50.0,
              child: const Icon(
                Icons.local_pharmacy_rounded,
                color: AppColors.rojo,
                size: 40.0,
              ),
            ),
          );
        }
      }
      if (controlador.farmacias!.first.latitud != null) {
        puntoCentral = LatLng(
          controlador.farmacias!.first.latitud!,
          controlador.farmacias!.first.longitud!,
        );
      }
    }

    return Stack(
      children: [
        FlutterMap(
          key: ValueKey(puntoCentral),
          options: MapOptions(initialCenter: puntoCentral, initialZoom: 15.0),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.weather',
            ),
            MarkerLayer(markers: marcadores),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'mapa_completo',
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            elevation: 4,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaMapaCompleto(
                    puntoCentral: puntoCentral,
                    marcadores: marcadores,
                  ),
                ),
              );
            },
            child: const Icon(
              Icons.fullscreen_rounded,
              color: AppColors.principal,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirSeccionClima(
    WeatherScreenController controlador,
    bool esVertical,
  ) {
    final ObservacionMeteo clima = controlador.observacionMeteo!;

    String formatearDato(double valor, String unidad) {
      if (valor <= -30000) return 'N/A';
      return '$valor $unidad';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Indicadores Climáticos',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w900,
              color: AppColors.principal,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: esVertical ? 2 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          childAspectRatio: esVertical ? 1.5 : 2.5,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _construirTarjetaDato(
              Icons.thermostat_rounded,
              'Temperatura',
              formatearDato(clima.temperatura, 'ºC'),
              AppColors.naranjaPrimario,
            ),
            _construirTarjetaDato(
              Icons.water_drop_rounded,
              'Humedad',
              formatearDato(clima.humedad, '%'),
              AppColors.azulAcentuado,
            ),
            _construirTarjetaDato(
              Icons.wb_sunny_rounded,
              'Índice UV',
              clima.ultravioleta <= -30000 ? 'N/A' : '${clima.ultravioleta}',
              AppColors.naranjaPrimario,
            ),
            _construirTarjetaDato(
              Icons.air_rounded,
              'Viento',
              formatearDato(clima.velocidadViento, 'km/h'),
              AppColors.verde,
            ),
            _construirTarjetaDato(
              Icons.speed_rounded,
              'Presión',
              formatearDato(clima.presion, 'hPa'),
              AppColors.gris,
            ),
            _construirTarjetaDato(
              Icons.umbrella_rounded,
              'Lluvia',
              formatearDato(clima.precipitacion, 'mm'),
              AppColors.azulAcentuado,
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirTarjetaDato(
    IconData icono,
    String titulo,
    String valor,
    Color colorIcono,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.gris.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icono, color: colorIcono, size: 24),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gris,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 18.0,
              color: AppColors.principal,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionFarmacias(
    BuildContext context,
    WeatherScreenController controlador,
  ) {
    final farmacias = controlador.farmacias ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Farmacia de Turno Mas Cercana',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w900,
              color: AppColors.principal,
            ),
          ),
        ),
        if (farmacias.isEmpty)
          const Text('No hay farmacias de turno activas en este sector.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: farmacias.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final farmacia = farmacias[index];

              String dirOriginal =
                  farmacia.direccion ?? 'Dirección no disponible';
              String dirLimpia = dirOriginal
                  .replaceAll(
                    RegExp(r',?\s*TURNOS\s*', caseSensitive: false),
                    '',
                  )
                  .trim();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gris.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () =>
                        _mostrarDetallesFarmacia(context, farmacia, dirLimpia),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.rojo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.local_pharmacy_rounded,
                          color: AppColors.rojo,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        farmacia.nombre ?? 'Farmacia',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.0,
                          color: AppColors.principal,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          dirLimpia,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.gris,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.acentoVibrante,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _mostrarDetallesFarmacia(
    BuildContext context,
    Farmacia farmacia,
    String dirLimpia,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: AppColors.grisClaro,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.rojo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy_rounded,
                      color: AppColors.rojo,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      farmacia.nombre ?? 'Farmacia',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.principal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _construirFilaInfoExtra(
                Icons.location_on_rounded,
                'Dirección',
                dirLimpia,
              ),

              if (farmacia.telefono != null &&
                  farmacia.telefono != '0' &&
                  farmacia.telefono!.isNotEmpty) ...[
                const Divider(
                  height: 40,
                  color: AppColors.grisClaro,
                  thickness: 2,
                ),
                _construirFilaInfoExtra(
                  Icons.phone_rounded,
                  'Teléfono',
                  farmacia.telefono!,
                ),
              ],

              const Divider(
                height: 40,
                color: AppColors.grisClaro,
                thickness: 2,
              ),
              _construirFilaInfoExtra(
                Icons.access_time_filled_rounded,
                'Horario',
                'Turno MINSAL vigente',
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.acentoVibrante,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _construirFilaInfoExtra(IconData icono, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: AppColors.acentoVibrante, size: 28),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.gris,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: AppColors.principal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PantallaMapaCompleto extends StatelessWidget {
  final LatLng puntoCentral;
  final List<Marker> marcadores;

  const PantallaMapaCompleto({
    super.key,
    required this.puntoCentral,
    required this.marcadores,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapa Detallado',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.principal,
        elevation: 1,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: puntoCentral,
          initialZoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.weather',
          ),
          MarkerLayer(markers: marcadores),
        ],
      ),
    );
  }
}
