import 'package:finalpoo_turina/styles.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:finalpoo_turina/qr_storage.dart';
import 'package:flutter/foundation.dart'; // Para el manejo de la lista
import 'qr_clases.dart';
import 'package:intl/intl.dart';

class MyQRsPage extends StatefulWidget {
  static List<QREstatico> generatedQRs = []; // Lista de objetos QR

  // Método para agregar un QR a la lista de QRs generados
  static Future<void> addGeneratedQR(QREstatico qr, String users) async {
    if (!generatedQRs.any((existingQR) => existingQR.id == qr.id)) {
      await QRStorage.addGeneratedQRToFirestore(
          qr, users); // Esperamos que Firestore termine
      generatedQRs.add(qr);
      QRStorage.saveQRsToFile(
          generatedQRs); // Guardamos el nuevo QR en el archivo
    }
  }

  // Método asíncrono para cargar todos los QRs desde Firestore y archivos
  static Future<void> loadAllQRs() async {
    print("Cargando todos los QRs..."); // Mensaje de depuración

    final fileQRs =
        <QREstatico>[]; // Lista para almacenar los QRs desde el archivo
    final firestoreQRs =
        await QRStorage.loadQRsFromFirestore(); // Cargar QRs desde Firestore

    await QRStorage.loadQRsFromFile(fileQRs); // Cargar QRs desde el archivo

    // Usar un Map para asegurarse de que los QRs sean únicos por su ID
    final allQRsMap = <String, QREstatico>{};

    for (var qr in [...fileQRs, ...firestoreQRs]) {
      if (qr != null) {
        allQRsMap[qr.getId()] =
            qr; // Insertar el QR en el mapa, sobrescribiendo duplicados por ID
      }
    }

    // Obtener la lista de todos los QRs sin duplicados
    final allQRs = allQRsMap.values.toList();

    // Si los datos nuevos son distintos a los actuales, actualizar la lista
    if (!listEquals(allQRs, generatedQRs)) {
      generatedQRs = allQRs;
      print("QRs cargados y actualizados: ${generatedQRs.length}");
      for (var qr in firestoreQRs) {
        print('ID del QR: ${qr.getId()}');
      }
    } else {
      print("Los QRs ya están actualizados.");
    }
  }

  @override
  _MyQRsPageState createState() => _MyQRsPageState();
}

class _MyQRsPageState extends State<MyQRsPage> {
  QRStorage almacenamiento = QRStorage();

  @override
  void initState() {
    super.initState();
    MyQRsPage.loadAllQRs().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis QR\'s'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              setState(() {
                MyQRsPage.generatedQRs.clear(); // Limpia la lista en memoria
              });

              // Borra el archivo local directamente
              await QRStorage.deleteLocalFile();
              await QRStorage.deleteAllQRsFromFirestore();

              // Opcional: Recargar desde Firestore para sincronizar
              await MyQRsPage.loadAllQRs();
              setState(() {}); // Actualiza la UI con los datos recargados
            },
          ),
        ],
      ),
      body: MyQRsPage.generatedQRs.isEmpty
          ? const Center(child: Text("No hay QRs generados."))
          : ListView.builder(
              itemCount: MyQRsPage.generatedQRs.length,
              itemBuilder: (context, index) {
                // Aquí estamos trabajando con un objeto QREstatico
                final qr = MyQRsPage.generatedQRs[index];

                // Ahora obtenemos el id y el alias de cada objeto QREstatico
                final id = qr.id;
                final alias = qr.alias;

                return ListTile(
                  title: Text(alias), // Muestra el alias
                  subtitle: Text("ID: $id"), // Muestra el ID
                  onTap: () => _showQR(qr), // Pasa la URL generada al mostrarlo
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await MyQRsPage.loadAllQRs();
          setState(() {});
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Actualizar QR\'s',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showQR(QREstatico qrparticular) {
    final id = qrparticular.getId();
    final alias = qrparticular.getAlias();
    final qrUrl = "https://finalpoo-turinajorge.web.app/validador/?qr=$id";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alias,
            style: const TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              child: QrImageView(data: qrUrl, size: 100.0),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el popup actual
                _showQRInfo(
                    qrparticular); // Abre el nuevo popup con información
              },
              child: const Text('Información'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                _borrarQR(qrparticular);
              },
              child: const Text('Eliminar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showQRInfo(QREstatico qrparticular) async {
    final alias = qrparticular.getAlias();
    final url = qrparticular.url;
    final formateador = DateFormat('yyyy-MM-dd HH:mm:ss');
    final creacionFormateada = formateador.format(qrparticular.fechaCreacion);
    final escaneado = qrparticular.vecesEscaneado;
    final ingresado = qrparticular.vecesIngresado;
    String? usuariosPermitidos =
        await QRStorage.getUsuariosPermitidos(qrparticular.getId());
    usuariosPermitidos ??=
        "todos"; // si es nulo asigna "todos", recomendado por compilador

    String? expiracionFormateada;
    // Comprueba si el QR es del tipo QRDinamico para acceder a la fecha de expiración
    if (qrparticular is QRdinamico) {
      final expiracion = qrparticular.fechaExpiracion;
      expiracionFormateada = formateador.format(expiracion);
    }

    // Obtener información adicional
    final List<Map<String, dynamic>> informacion =
        await almacenamiento.obtenerInformacion(qrparticular.getId());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Información de $alias', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          // Agrega scroll al contenido
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment:
                    Alignment.center, // Alinea el botón al centro horizontal
                child: TextButton(
                  onPressed: () {
                    // Lógica para agregar información
                    Navigator.of(context).pop();
                    _agregar_informacion(qrparticular);
                  },
                  child: Text('Agregar Información'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, // Cambia el color del texto
                    backgroundColor: AppColors.primary,
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              qrparticular is QRdinamico
                  ? Row(
                      children: [
                        Text('Tipo: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Dinamico'),
                      ],
                    )
                  : Row(
                      children: [
                        Text('Tipo: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Estatico'),
                      ],
                    ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Alias: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(alias),
                ],
              ),
              Row(
                children: [
                  Text('Contenido del QR: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(url),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Creacion: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(creacionFormateada),
                ],
              ),
              if (qrparticular is QRdinamico)
                Row(
                  children: [
                    Text('Expiracion :',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$expiracionFormateada'),
                  ],
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Escaneado: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(escaneado),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Ingresado: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(ingresado),
                ],
              ),
              SizedBox(height: 10),
              Text('usuarios permitidos:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('$usuariosPermitidos'),
              SizedBox(height: 10),
              Text(
                'Información adicional:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (informacion.isNotEmpty)
                ...informacion.map((info) {
                  final timestamp = info['timestamp'] != null
                      ? formateador.format(info['timestamp'].toDate())
                      : 'Sin timestamp';
                  final mensaje = info['mensaje'] ?? 'Sin mensaje';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text('- $mensaje (Fecha: $timestamp)'),
                  );
                }).toList()
              else
                Text('No hay información disponible.'),
              const SizedBox(height: 500),
              Text(
                'Este código QR es usado para XYZ...',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _agregar_informacion(QREstatico qrparticular) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context, // context sigue siendo necesario aquí
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Información - ${qrparticular.getAlias()}',
              textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingrese la información:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  maxLines: 3, // Permite múltiples líneas
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Escribe algo aquí...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final String inputText = _controller.text.trim();
                if (inputText.isNotEmpty) {
                  print(
                      "Información a guardar para ${qrparticular.getAlias()}: $inputText");
                  _confirmarAgregarInformacion(qrparticular,
                      inputText); // Llama a otra función si es necesario
                }
                //Navigator.of(context).pop(); // Cierra el diálogo después de guardar
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarAgregarInformacion(QREstatico qr, String nuevaInfo) {
    final id = qr.getId();
    _mostrarConfirmacion(
      context: context,
      titulo: '¿Agregar Información?',
      mensaje: 'Vas a agregar esta información: "$nuevaInfo" al QR:"$id ".',
      onConfirmar: () {
        almacenamiento.agregarNuevaInformacion(qr, nuevaInfo);
        Navigator.of(context).pop();
      },
    );
  }

  void _borrarQR(QREstatico qr) async {
    _mostrarConfirmacion(
      context: context,
      titulo: '¿Estás seguro?',
      mensaje:
          'Vas a borrar el QR: "${qr.getAlias()}". Esta acción no se puede deshacer.',
      onConfirmar: () async {
        Navigator.of(context).pop();
        MyQRsPage.generatedQRs.remove(qr);
        await QRStorage.deleteQRFromFirestore(qr.getId());
        await QRStorage.saveQRsToFile(MyQRsPage.generatedQRs);
        setState(() {}); //para que rebuildee el listado
        print("QR eliminado: ${qr.getAlias()}");
      },
    );
  }
}

void _mostrarConfirmacion({
  required BuildContext context,
  required String titulo,
  required String mensaje,
  required VoidCallback onConfirmar,
  VoidCallback? onCancelar,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(titulo, textAlign: TextAlign.center),
        content: Text(mensaje, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: onCancelar ??
                () => Navigator.of(context)
                    .pop(), // Cerrar si no hay acción personalizada
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(); // Cerrar el diálogo antes de confirmar
              onConfirmar(); // Ejecutar la acción confirmada
            },
            child: Text('Confirmar'),
          ),
        ],
      );
    },
  );
}
