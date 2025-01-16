class QREstatico {
  final String url;
  final String alias;
  final DateTime fechaCreacion;
  final String owner;

  QREstatico({
    required this.url,
    required this.alias,
    required this.fechaCreacion,
    required this.owner,
  });

  String getAlias() {
    return alias;
  }

   String toString() {
    return "$url|$alias|${fechaCreacion.toIso8601String()}|$owner";
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
  }) : super(
          url: url,
          alias: alias,
          fechaCreacion: fechaCreacion,
          owner: owner,
        );

  @override
  String toString() {
    // Ahora no llamamos a super.toString(), sino que construimos la cadena directamente.
    return "$url|$alias|${fechaExpiracion.toIso8601String()}|${fechaCreacion.toIso8601String()}|$owner";
  }
}