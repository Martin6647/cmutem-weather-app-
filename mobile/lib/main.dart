import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/controller/weather_screen_controller.dart';
import 'package:weather/screen/login_screen.dart';
import 'package:weather/screen/dashboard_screen.dart';
import 'package:weather/services/servicio_google.dart';
import 'package:weather/services/servicio_rest.dart';
import 'package:weather/services/servicio_ubicacion.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider<ServicioRest>(create: (_) => ServicioRest()),
        Provider<ServicioUbicacion>(create: (_) => ServicioUbicacion()),
        Provider<ServicioGoogle>(create: (_) => ServicioGoogle()),
        ChangeNotifierProxyProvider3<
          ServicioRest,
          ServicioUbicacion,
          ServicioGoogle,
          WeatherScreenController
        >(
          create: (context) => WeatherScreenController(
            servicioRest: context.read<ServicioRest>(),
            servicioUbicacion: context.read<ServicioUbicacion>(),
            servicioGoogle: context.read<ServicioGoogle>(),
          ),
          update: (_, rest, ubi, google, prev) =>
              prev ??
              WeatherScreenController(
                servicioRest: rest,
                servicioUbicacion: ubi,
                servicioGoogle: google,
              ),
        ),
      ],
      child: const UtemWeatherApp(),
    ),
  );
}

class UtemWeatherApp extends StatelessWidget {
  const UtemWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTEM Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ControladorSesion(),
    );
  }
}

class ControladorSesion extends StatefulWidget {
  const ControladorSesion({super.key});

  @override
  State<ControladorSesion> createState() => _ControladorSesionState();
}

class _ControladorSesionState extends State<ControladorSesion> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final token = await context.read<ServicioGoogle>().obtenerToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
    );
  }
}
