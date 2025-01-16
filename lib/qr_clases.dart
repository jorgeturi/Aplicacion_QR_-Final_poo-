class QREstatico {
  final String url;
  final String alias;
  final DateTime fechaCreacion;
  final String owner;
  String id;

  QREstatico({
    required this.url,
    required this.alias,
    required this.fechaCreacion,
    required this.owner,
    required this.id,
  });

  String getAlias() {
    return alias;
  }

  String getId(){
    return id;
  }

  set setId(String newId) {
    id = newId;
  }

   String toString() {
    return "$url|$alias|${fechaCreacion.toIso8601String()}|$owner";
  }


   // Método para convertir el objeto a un mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'alias': alias,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'owner': owner,
      'id': id,
    };
  }

  // Método de fábrica para crear un objeto desde un mapa (JSON)
  factory QREstatico.fromJson(Map<String, dynamic> json) {
    return QREstatico(
      url: json['url'],
      alias: json['alias'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      owner: json['owner'],
      id: json['id'],
    );
  }
}

class QRdinamico extends QREstatico {
  final DateTime fechaExpiracion;

  QRdinamico({
    required String url,
    required String alias,
    required DateTime fechaCreacion,
    required String owner,
    required this.fechaExpiracion,
    required String id,
  }) : super(
          url: url,
          alias: alias,
          fechaCreacion: fechaCreacion,
          owner: owner,
          id: id,
        );

  @override
  String toString() {
    // Ahora no llamamos a super.toString(), sino que construimos la cadena directamente.
    return "$url|$alias|${fechaExpiracion.toIso8601String()}|${fechaCreacion.toIso8601String()}|$owner";
  }

  // Método para convertir el objeto a un mapa (JSON)
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['fechaExpiracion'] = fechaExpiracion.toIso8601String();
    return json;
  }

  // Método de fábrica para crear un objeto desde un mapa (JSON)
  factory QRdinamico.fromJson(Map<String, dynamic> json) {
    return QRdinamico(
      url: json['url'],
      alias: json['alias'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      owner: json['owner'],
      fechaExpiracion: DateTime.parse(json['fechaExpiracion']),
      id: json['id'],
    );
  }
}