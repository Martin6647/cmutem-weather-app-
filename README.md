# UTEM Weather App

Aplicación integral para monitoreo meteorológico y gestión de farmacias de turno desarrollada como ejemplo para la asignatura de Computación Móvil para la Universidad Tecnológica Metropolitana del Estado de Chile (UTEM).

## Descripción General

UTEM Weather App es un sistema distribuido que integra una aplicación móvil, un servicio REST API y un servicio programado (scheduler) para proporcionar información meteorológica en tiempo real y ubicación de farmacias de turno. La aplicación está diseñada como proyecto educativo para la especialidad de Computación Móvil.

### Objetivos Principales

1. Proporcionar acceso a datos meteorológicos en tiempo real a través de una interfaz móvil intuitiva.
2. Integrar información geoespacial para localizar servicios de farmacia disponibles.
3. Demostrar patrones arquitectónicos modernos en desarrollo móvil, servicios web y procesamiento de datos.
4. Validar identidades de usuario mediante integración con servicios de autenticación de terceros.

## Arquitectura del Sistema

El sistema implementa una arquitectura en capas distribuida con los siguientes componentes:

### Componentes Principales

#### 1. Aplicación Móvil (mobile/)

Aplicación nativa desarrollada en Flutter que permite a los usuarios consultar datos meteorológicos y localizar farmacias de turno.

**Características principales:**
- Autenticación mediante Google Sign-In
- Geolocalización en tiempo real mediante GPS
- Consultas de datos meteorológicos en tiempo real
- Búsqueda de farmacias de turno cercanas
- Almacenamiento seguro de credenciales
- Interfaz responsive con Material Design 3

**Tecnologías utilizadas:**
- Flutter SDK 3.12.1+
- Provider 6.1.5 para gestión de estado
- Dio 5.9.2 para comunicación HTTP
- google_sign_in 7.2.0 para autenticación
- geolocator 14.0.3 para servicios de localización
- flutter_map 8.3.1 para visualización cartográfica

#### 2. Servicio REST API (ReST/)

Servicio web desarrollado en Spring Boot que expone endpoints REST para consultas de datos meteorológicos y gestión de farmacias de turno.

**Responsabilidades:**
- Validar tokens de autenticación Google
- Exponer datos meteorológicos consultables por ubicación
- Proporcionar información de farmacias de turno
- Gestionar errores centralizados y validación de datos
- Servir documentación OpenAPI interactiva

**Tecnologías utilizadas:**
- Spring Boot 4.1.0
- Java 21
- Spring Data JPA para acceso a datos
- springdoc-openapi 3.0.3 para documentación API
- Maven para gestión de dependencias

#### 3. Servicio Programado (scheduler/)

Servicio backend encargado de tareas programadas, específicamente la ingesta de datos meteorológicos desde fuentes externas.

**Responsabilidades:**
- Consumir datos meteorológicos de la API RedMeteo
- Persistir observaciones meteorológicas en la base de datos
- Actualizar información de farmacias de turno
- Mantener la consistencia de datos históricos

**Tecnologías utilizadas:**
- Spring Boot 4.1.0
- Java 21
- Spring Scheduling para ejecución programada
- Apache Commons para utilidades

#### 4. Base de Datos (db/)

Sistema de gestión de base de datos PostgreSQL con extensión PostGIS para consultas geoespaciales avanzadas.

**Características:**
- Almacenamiento de estaciones meteorológicas con coordenadas geográficas
- Historial de observaciones meteorológicas
- Catálogo de farmacias con información de turnos
- Índices geoespaciales para consultas optimizadas
- Soporte para tipos de datos PostGIS

## Requisitos Previos

### Software Requerido

- Java Development Kit (JDK) versión 21 o superior
- Flutter SDK versión 3.12.1 o superior
- PostgreSQL versión 14 o superior con extensión PostGIS
- Apache Maven 3.8 o superior (incluido mediante wrapper)
- Git para control de versiones

### Dependencias Externas

- API de RedMeteo para datos meteorológicos
- Google Cloud Console con credenciales de OAuth 2.0 para autenticación
- Acceso a base de datos PostgreSQL con permisos de creación de esquema

## Instalación y Configuración

### 1. Clonar el Repositorio

```bash
git clone https://github.com/sebasalazar/utem-weather-app.git
cd utem-weather-app
```

### 2. Configurar Base de Datos

Asegúrese de que PostgreSQL esté en ejecución y crear la base de datos:

```bash
createdb utemdb
psql -U postgres -d utemdb -c "CREATE EXTENSION postgis;"
```

Inicializar el esquema de base de datos:

```bash
psql -U postgres -d utemdb -f db/01-model.sql
```

Verificar las credenciales en `ReST/src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:postgresql:utemdb
spring.datasource.username=cm
spring.datasource.password=Utem,2026
```

### 3. Configurar Aplicación Móvil

Navegar al directorio móvil e instalar dependencias:

```bash
cd mobile
flutter pub get
```

Configurar credenciales de Google Sign-In en los archivos de configuración nativa:
- Android: `mobile/android/app/src/main/AndroidManifest.xml`
- iOS: `mobile/ios/Runner/Info.plist`

### 4. Configurar Servicios Backend

Los servicios REST y Scheduler utilizan Maven como gestor de dependencias. Las dependencias se descargarán automáticamente durante la construcción.

```bash
# Compilar REST API
cd ReST
./mvnw clean install

# Compilar Scheduler
cd ../scheduler
./mvnw clean install
```

## Uso

### Ejecutar en Ambiente de Desarrollo

#### Base de Datos

Asegúrese de que PostgreSQL esté en ejecución:

```bash
# En Linux/macOS
sudo systemctl start postgresql

# En Windows
net start PostgreSQL-x64-14
```

#### Servicio REST API

```bash
cd ReST
./mvnw spring-boot:run
```

El servicio estará disponible en `http://localhost:8080/cmutem`

Documentación OpenAPI: `http://localhost:8080/cmutem/swagger-ui.html`

#### Servicio Scheduler

```bash
cd scheduler
./mvnw spring-boot:run
```

#### Aplicación Móvil

```bash
cd mobile
flutter run
```

### Compilación para Producción

#### Aplicación Móvil

```bash
# Compilar APK para Android
cd mobile
flutter build apk --release

# Compilar para iOS
flutter build ios --release
```

#### Servicios Backend

```bash
# Compilar REST API
cd ReST
./mvnw clean package -DskipTests

# Compilar Scheduler
cd scheduler
./mvnw clean package -DskipTests
```

Se generarán archivos WAR en los directorios `target/` de cada proyecto.

## Pruebas

### Pruebas de Aplicación Móvil

```bash
cd mobile
flutter test
```

Ejecuta pruebas unitarias y de widgets definidas en `test/`

### Pruebas de Servicios Backend

```bash
# Pruebas unitarias - REST API
cd ReST
./mvnw test

# Pruebas de integración (requiere base de datos)
./mvnw verify

# Pruebas unitarias - Scheduler
cd scheduler
./mvnw test
```

## Estructura del Proyecto

```
utem-weather-app/
├── mobile/                          # Aplicación Flutter
│   ├── lib/
│   │   ├── main.dart               # Punto de entrada
│   │   ├── consts/                 # Constantes y configuración de UI
│   │   ├── model/                  # Modelos de dominio
│   │   ├── screen/                 # Pantallas (Login, Weather, etc.)
│   │   ├── controller/             # Controladores con Provider
│   │   ├── services/               # Servicios (REST, Google Auth, Location)
│   │   └── widgets/                # Componentes reutilizables
│   ├── pubspec.yaml               # Dependencias Flutter
│   └── analysis_options.yaml      # Configuración de linting
│
├── ReST/                            # Servicio REST API
│   ├── src/main/java/
│   │   └── cl/sebastian/cm/rest/
│   │       ├── api/                # Controladores REST
│   │       ├── domain/             # Entidades JPA
│   │       ├── manager/            # Lógica de negocio
│   │       ├── exception/          # Excepciones personalizadas
│   │       ├── utils/              # Utilidades
│   │       └── conf/               # Configuración OpenAPI
│   ├── src/main/resources/
│   │   └── application.properties  # Propiedades Spring Boot
│   ├── pom.xml                     # Dependencias Maven
│   └── .mvn/                       # Wrapper de Maven
│
├── scheduler/                       # Servicio Programado
│   ├── src/main/java/
│   │   └── cl/sebastian/cm/scheduler/
│   ├── pom.xml                     # Dependencias Maven
│   └── .mvn/                       # Wrapper de Maven
│
├── db/                              # Base de Datos
│   └── 01-model.sql               # Schema PostgreSQL con PostGIS
│
├── README.md                        # Este archivo
└── LICENSE                          # Licencia Apache 2.0
```

## Modelos de Datos Principales

### Estaciones Meteorológicas (stations)

Representa puntos de recolección de datos meteorológicos con información geoespacial:

- Código y nombre identificadores
- Coordenadas geográficas (latitud, longitud)
- Altitud sobre el nivel del mar
- Estado de actividad
- Timestamps de auditoría

### Observaciones Meteorológicas (observations)

Registra datos meteorológicos recolectados en tiempo real:

- Referencia a estación meteorológica
- Parámetros climáticos (temperatura, humedad, presión, etc.)
- Timestamp de observación
- Información de auditoría

### Farmacias (pharmacies)

Catalogo de establecimientos farmacéuticos con información de ubicación y horarios:

- Identificador de comercio y tienda
- Nombre y dirección
- Teléfono de contacto
- Horarios de operación
- Coordenadas geográficas
- Índices geoespaciales para búsquedas eficientes

### Farmacias de Turno (pharmacies_on_duty)

Registro de farmacias disponibles para turnos específicos:

- Fecha de turno
- Referencia a farmacia
- Timestamps de auditoría
- Índice único para evitar duplicados

## Flujos Principales

### Autenticación y Login

1. Usuario inicia sesión en la aplicación móvil
2. Google Sign-In autentica el usuario y retorna un token ID
3. Aplicación móvil envía el token al servicio REST API
4. REST API valida el token con Google mediante GoogleAuthUtils
5. API retorna datos del usuario o error de autenticación
6. Aplicación accede a funcionalidades protegidas

### Consulta de Datos Meteorológicos

1. Usuario solicita datos meteorológicos para su ubicación actual
2. Aplicación móvil obtiene coordenadas mediante geolocator
3. Aplicación envía consulta al servicio REST API
4. API utiliza MeteoManager para buscar estaciones cercanas
5. API realiza búsqueda geoespacial utilizando PostGIS
6. Retorna observaciones meteorológicas más recientes
7. Aplicación visualiza datos en interfaz

### Ingesta de Datos Meteorológicos

1. Scheduler ejecuta tarea programada (intervalo configurable)
2. Scheduler consume datos de API RedMeteo
3. Procesa y valida información meteorológica
4. Persiste observaciones en base de datos
5. Actualiza timestamps de última sincronización
6. Registra errores en log para auditoría

## Configuración de Propiedades

### Aplicación REST

Archivo: `ReST/src/main/resources/application.properties`

Propiedades importantes:

```properties
spring.application.name=cmutem
server.servlet.context-path=/cmutem
spring.datasource.url=jdbc:postgresql:utemdb
spring.datasource.username=cm
spring.datasource.password=Utem,2026
spring.jpa.hibernate.ddl-auto=validate
max.distance=15000
```

- `max.distance`: Radio máximo en metros para búsquedas geoespaciales (default: 15000m)
- `spring.jpa.hibernate.ddl-auto`: Configurar a `validate` en producción, `update` en desarrollo

## Consideraciones de Seguridad

1. **Autenticación**: Utiliza Google OAuth 2.0 para validación de identidad
2. **Almacenamiento de Credenciales**: Credenciales de usuario se almacenan en flutter_secure_storage, no en SharedPreferences
3. **Validación de Tokens**: Todos los tokens se validan en servidor mediante GoogleAuthUtils
4. **Encriptación de Tránsito**: Conexiones HTTPS en producción
5. **Base de Datos**: Credenciales configurables mediante environment variables en producción

## Contribución

Para contribuir al proyecto:

1. Crear una rama a partir de `dev`
2. Realizar cambios y pruebas
3. Crear un pull request con descripción clara
4. Asegurar que todas las pruebas pasen
5. Obtener aprobación de revisión de código

## Licencia

Este proyecto está bajo licencia Apache License 2.0. Consulte el archivo LICENSE para más detalles.

## Contacto e Información de Desarrollo

**Desarrollador Principal**: Sebastián Salazar Molina (ssalazar@utem.cl)

**Institución**: Universidad Tecnológica Metropolitana del Estado de Chile (UTEM)

**Repositorio**: https://github.com/sebasalazar/utem-weather-app

Para reportar problemas o sugerencias, favor contactar al equipo de desarrollo o crear un issue en el repositorio.

## Bibliografía y Referencias

- Flutter Documentation: https://docs.flutter.dev/
- Spring Boot Reference: https://spring.io/projects/spring-boot
- PostgreSQL PostGIS: https://postgis.net/
- Google Sign-In: https://developers.google.com/identity
- OpenAPI Specification: https://spec.openapis.org/

---

Última actualización: julio 2026
Versión: 0.9.9
