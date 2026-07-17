import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/consts/app_colors.dart';
import 'package:weather/screen/dashboard_screen.dart';
import 'package:weather/screen/login_screen.dart';
import 'package:weather/screen/weather_screen.dart';
import 'package:weather/services/servicio_google.dart';

class MyMenu extends StatelessWidget {
  const MyMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.fondo,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 32,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.acentoVibrante, AppColors.azulAcentuado],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.fondo,
                    child: Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: AppColors.principal,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estudiante UTEM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conectado vía Google',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _construirOpcion(
            context: context,
            icono: Icons.home_rounded,
            titulo: 'Resumen Inicial',
            alPresionar: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
          _construirOpcion(
            context: context,
            icono: Icons.map_rounded,
            titulo: 'Panel de Monitoreo',
            alPresionar: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WeatherScreen()),
              );
            },
          ),
          const SizedBox(height: 40),
          const Divider(
            color: AppColors.grisClaro,
            thickness: 2,
            indent: 24,
            endIndent: 24,
          ),
          const SizedBox(height: 8),
          _construirOpcion(
            context: context,
            icono: Icons.logout_rounded,
            titulo: 'Cerrar Sesión',
            colorReemplazo: AppColors.rojo,
            alPresionar: () async {
              await context.read<ServicioGoogle>().cerrarSesion();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _construirOpcion({
    required BuildContext context,
    required IconData icono,
    required String titulo,
    required VoidCallback alPresionar,
    Color? colorReemplazo,
  }) {
    final color = colorReemplazo ?? AppColors.principal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icono, color: color, size: 28),
        title: Text(
          titulo,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        hoverColor: color.withValues(alpha: 0.1),
        splashColor: color.withValues(alpha: 0.1),
        onTap: alPresionar,
      ),
    );
  }
}
