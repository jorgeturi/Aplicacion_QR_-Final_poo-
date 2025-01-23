class QREstatico {
  final String _url; // Atributo privado
  final String _alias; // Atributo privado
  final DateTime _fechaCreacion; // Atributo privado
  final String _owner; // Atributo privado
  String _id; // Atributo privado
  final String _vecesEscaneado; // Atributo privado
  final String _vecesIngresado; // Atributo privado

  // Constructor con parámetros nombrados
  QREstatico({
    required String url, // Parámetro del constructor
    required String alias,
    required DateTime fechaCreacion,
    required String owner,
    required String id,
    required String vecesEscaneado,
    required String vecesIngresado,
  })  : _url = url, // Asignación del parámetro a los campos privados
        _alias = alias,
        _fechaCreacion = fechaCreacion,
        _owner = owner,
        _id = id,
        _vecesEscaneado = vecesEscaneado,
        _vecesIngresado = vecesIngresado;

  String getAlias() {
    return _alias;
  }

  String getId() {
    return _id;
  }

  String getUrl() {
    return _url;
  }

  DateTime getFechaCreacion() {
    return _fechaCreacion;
  }

  String getVecesEscaneado() {
    return _vecesEscaneado;
  }

  String getOwner() {
    return _owner;
  }

  String getVecesIngresado() {
    return _vecesIngresado;
  }

  set setId(String newId) {
    _id = newId;
  }

  @override
  String toString() {
    return "$_url|$_alias|${_fechaCreacion.toIso8601String()}|$_owner|$_vecesEscaneado|$_vecesIngresado|$_id";
  }

  // Método para convertir el objeto a un mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'url': _url,
      'alias': _alias,
      'fechaCreacion': _fechaCreacion.toIso8601String(),
      'owner': _owner,
      'id': _id,
      'vecesEscaneado': _vecesEscaneado,
      'vecesIngresado': _vecesIngresado,
    };
  }

  // Método de fábrica para crear un objeto desde un mapa (JSON)
  factory QREstatico.fromJson(Map<String, dynamic> json) {
    return QREstatico(
      url: json['url'] ?? '', // Asignar un valor por defecto si es null
      alias: json['alias'] ?? '', // Asignar un valor por defecto si es null
      fechaCreacion: DateTime.parse(
          json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      owner: json['owner'] ?? '', // Asignar un valor por defecto si es null
      id: json['id'] ?? '', // Asignar un valor por defecto si es null
      vecesEscaneado: json['vecesEscaneado'] ??
          '0', // Asignar un valor por defecto si es null
      vecesIngresado: json['vecesIngresado'] ??
          '0', // Asignar un valor por defecto si es null
    );
  }
}

class QRdinamico extends QREstatico {
  final DateTime _fechaExpiracion;

  QRdinamico({
    required String url,
    required String alias,
    required DateTime fechaCreacion,
    required String owner,
    required fechaExpiracion,
    required String id,
    required String vecesEscaneado,
    required String vecesIngresado,
  })  : _fechaExpiracion = fechaExpiracion,
        super(
          url: url,
          alias: alias,
          fechaCreacion: fechaCreacion,
          owner: owner,
          id: id,
          vecesEscaneado: vecesEscaneado,
          vecesIngresado: vecesIngresado,
        );

  DateTime getFechaExpiracion() {
    return _fechaExpiracion;
  }

  @override
  String toString() {
    return "$getUrl()|$getAlias()|${getFechaExpiracion().toIso8601String()}|${getFechaCreacion().toIso8601String()}|$getOwner()|$getVecesEscaneado()|$getVecesIngresado()|$getId()";
  }

  // Método para convertir el objeto a un mapa (JSON)
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['fechaExpiracion'] = getFechaExpiracion().toIso8601String();
    return json;
  }

  // Método de fábrica para crear un objeto desde un mapa (JSON)
  factory QRdinamico.fromJson(Map<String, dynamic> json) {
    return QRdinamico(
      url: json['url'] ?? '',
      alias: json['alias'] ?? '',
      fechaCreacion: DateTime.parse(
          json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      owner: json['owner'] ?? '',
      fechaExpiracion: DateTime.parse(
          json['fechaExpiracion'] ?? DateTime.now().toIso8601String()),
      id: json['id'] ?? '',
      vecesEscaneado: json['vecesEscaneado'] ?? '0',
      vecesIngresado: json['vecesIngresado'] ?? '0',
    );
  }
}
