class Farmacia {
  final String? nombre;
  final String? direccion;
  final String? telefono;
  final double? latitud;
  final double? longitud;

  Farmacia({
    this.nombre,
    this.direccion,
    this.telefono,
    this.latitud,
    this.longitud,
  });

  factory Farmacia.fromJson(Map<String, dynamic> json) {
    double? parseCoordenada(dynamic valor) {
      if (valor == null) return null;
      if (valor is double) return valor;
      if (valor is int) return valor.toDouble();
      if (valor is String) return double.tryParse(valor);
      return null;
    }

    return Farmacia(
      nombre: json['nombre'] ?? json['local_nombre'] ?? json['tienda'],
      direccion: json['direccion'] ?? json['local_direccion'],
      telefono:
          json['telefono']?.toString() ?? json['local_telefono']?.toString(),
      latitud: parseCoordenada(
        json['latitude'] ?? json['local_lat'] ?? json['latitud'] ?? json['lat'],
      ),
      longitud: parseCoordenada(
        json['longitude'] ??
            json['local_lng'] ??
            json['longitud'] ??
            json['lng'],
      ),
    );
  }
}
