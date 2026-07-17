Panel de Monitoreo CMUTEM: Clima y Farmacias de Turno

**Desarrollado por:** Martin Cornejo Marquez
**Fecha de entrega:** 17 de julio de 2026

## Descripción del Proyecto
Aplicación móvil multiplataforma desarrollada en Flutter que ayuda a los usuarios a tomar decisiones informadas antes de salir de casa. La aplicación autentica al usuario mediante Google Sign-In, obtiene su ubicación en tiempo real mediante el GPS del dispositivo y consume una API REST para mostrar las condiciones climáticas actuales y la farmacia de turno más cercana, visualizando todo en un mapa interactivo.

## Arquitectura Utilizada
El proyecto está construido bajo una arquitectura de **Estado Reactivo utilizando Provider**, separando claramente las responsabilidades en distintas capas:

* **Models:** Clases de datos (`ObservacionMeteo`, `Farmacia`) con funciones de serialización (`fromJson`). Se implementó una lógica de "Safe Parsing" para manejar valores nulos o tipos de datos inconsistentes desde la API.
* **Services:** Archivos dedicados exclusivamente a la comunicación externa (`servicio_google.dart`, `servicio_ubicacion.dart`, `servicio_rest.dart`).
* **Controllers:** (`WeatherScreenController`) Contiene la lógica de negocio, orquesta las llamadas asíncronas y notifica a la vista los cambios de estado.
* **Screens / Widgets:** Capa de presentación (UI) construida de forma declarativa que reacciona a los cambios del controlador.

## Requisitos Previos
* **Flutter SDK:** Versión estable reciente.
* **Entorno de desarrollo:** VS Code o Android Studio.
* **Dispositivo:** Emulador de Android o teléfono físico conectado.

## Instrucciones de Instalación y Ejecución

1. Clonar el repositorio e instalar dependencias
Abre tu terminal y ejecuta los siguientes comandos:
```bash
git clone https://github.com/Martin6647/cmutem-weather-app-.git
cd cmutem-weather-app-
flutter pub get 
```
2. Configuración de Firebase (Google Sign-In)
Para que el inicio de sesión funcione, debes agregar el archivo de configuración:

Solicitar o generar el archivo google-services.json correspondiente al proyecto de Firebase.

Colocar este archivo en la ruta: android/app/google-services.json.

3. Configuración del Mapa (OpenStreetMap)
El proyecto utiliza el paquete flutter_map junto con los servidores de OpenStreetMap. Al no requerir API Key, funciona de manera inmediata.

4. Configuración del GPS (Para pruebas en Emulador)
Si vas a probar la aplicación en un emulador de Android Studio:

Abre el emulador.

Haz clic en los tres puntos (...) en la barra lateral del emulador.

Ve a la pestaña Location.

Busca una dirección dentro de Chile y presiona Set Location.

5. Ejecutar la aplicación
Una vez configurado Firebase y el GPS, compila el proyecto con:
```bash
flutter run
```
Resumen de Historias de Usuario Cumplidas
* **RU-01: Login fluido con Google y persistencia de sesión automática.**

* **RU-02: Solicitud de permisos GPS amigable y renderizado de mapas interactivos.**

* **RU-03: Consumo exitoso de Swagger (API REST) y cálculos de distancia entre el usuario y la farmacia.**