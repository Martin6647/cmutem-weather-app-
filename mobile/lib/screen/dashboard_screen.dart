import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather/consts/app_colors.dart';
import 'package:weather/controller/weather_screen_controller.dart';
import 'package:weather/screen/weather_screen.dart';
import 'package:weather/screen/login_screen.dart';
import 'package:weather/services/servicio_google.dart';
import 'package:weather/widgets/my_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controlador = context.read<WeatherScreenController>();
      if (!controlador.tieneDatos) {
        controlador.inicializarDatos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    String fechaTexto = '${now.day} de ${meses[now.month - 1]}, ${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // 🔥 1. APPBAR LIMPIA: Solo el menú de hamburguesa, sin el ícono de usuario
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.principal, size: 30),
      ),
      drawer: const MyMenu(),

      body: SafeArea(
        child: Consumer<WeatherScreenController>(
          builder: (context, controlador, child) {
            if (controlador.estaCargando) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.acentoVibrante),
                    SizedBox(height: 24),
                    Text(
                      'Analizando tu entorno...',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.principal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controlador.mensajeError != null) {
              return _construirError(context, controlador);
            }
            if (!controlador.tieneDatos) {
              return const Center(
                child: Text('No se pudieron cargar los datos.'),
              );
            }

            final clima = controlador.observacionMeteo!;
            final farmacias = controlador.farmacias ?? [];

            String tempTexto = clima.temperatura <= -30000
                ? 'N/A'
                : '${clima.temperatura.toStringAsFixed(1)}º';
            String estadoClima = clima.precipitacion > 0
                ? 'Lluvia detectada'
                : 'Cielo despejado';

            // Preparar variables extra para el dashboard
            String humStr = clima.humedad <= -30000
                ? 'N/A'
                : '${clima.humedad.toInt()}%';
            String uvStr = clima.ultravioleta <= -30000
                ? 'N/A'
                : '${clima.ultravioleta}';
            String vientoStr = clima.velocidadViento <= -30000
                ? 'N/A'
                : '${clima.velocidadViento.toInt()} km/h';

            String nombreFarmacia = 'Sin farmacias de turno';
            String direccionFarmacia = 'No hay resultados en tu zona';

            if (farmacias.isNotEmpty) {
              nombreFarmacia = farmacias.first.nombre ?? 'Farmacia de turno';
              String dirOriginal =
                  farmacias.first.direccion ?? 'Dirección no disponible';
              direccionFarmacia = dirOriginal
                  .replaceAll(
                    RegExp(r',?\s*TURNOS\s*', caseSensitive: false),
                    '',
                  )
                  .trim();

              if (farmacias.first.latitud != null &&
                  farmacias.first.longitud != null) {
                final distance = const Distance();
                final miUbicacion = LatLng(
                  controlador.coordenadaActual!.latitud,
                  controlador.coordenadaActual!.longitud,
                );
                final ubiFarmacia = LatLng(
                  farmacias.first.latitud!,
                  farmacias.first.longitud!,
                );
                final metros = distance.as(
                  LengthUnit.Meter,
                  miUbicacion,
                  ubiFarmacia,
                );
                String distStr = metros > 1000
                    ? '${(metros / 1000).toStringAsFixed(1)} km'
                    : '${metros.toInt()} m';

                direccionFarmacia =
                    '$direccionFarmacia\n📍 A $distStr de tu ubicación';
              }
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      'Bienvenido,',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.acentoVibrante,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Monitoreo actual',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.principal,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fechaTexto,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.gris,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // TARJETA DE CLIMA PRINCIPAL
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.acentoVibrante,
                            AppColors.azulAcentuado,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.acentoVibrante.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.wb_cloudy_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                              const Spacer(),
                              Text(
                                tempTexto,
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Condiciones actuales',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            estadoClima,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔥 2. FILA DE DETALLES RÁPIDOS: Humedad, UV, Viento
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _construirMiniTarjeta(
                          Icons.water_drop_rounded,
                          humStr,
                          'Humedad',
                        ),
                        _construirMiniTarjeta(
                          Icons.wb_sunny_rounded,
                          uvStr,
                          'Índice UV',
                        ),
                        _construirMiniTarjeta(
                          Icons.air_rounded,
                          vientoStr,
                          'Viento',
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'Farmacia de Turno más cercana',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.principal,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TARJETA DE FARMACIA
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gris.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(32),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WeatherScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.rojo.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_pharmacy_rounded,
                                    color: AppColors.rojo,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombreFarmacia,
                                        style: const TextStyle(
                                          color: AppColors.principal,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        direccionFarmacia,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.gris,
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 🔥 3. BOTÓN DE ACCIÓN PRINCIPAL PARA LLENAR EL ESPACIO
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WeatherScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.map_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Abrir Mapa y Detalles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.principal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.principal.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // WIDGET AUXILIAR PARA LAS MINI TARJETAS
  Widget _construirMiniTarjeta(IconData icono, String valor, String titulo) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.gris.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: AppColors.acentoVibrante, size: 28),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.principal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: const TextStyle(fontSize: 12, color: AppColors.gris),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirError(
    BuildContext context,
    WeatherScreenController controlador,
  ) {
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
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await context.read<ServicioGoogle>().cerrarSesion();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: AppColors.rojo,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
