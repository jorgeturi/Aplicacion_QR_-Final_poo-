import 'package:finalpoo_turina/styles.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/foundation.dart'; // Para el manejo de la lista
import 'qr_clases.dart';
import 'qr_manager.dart';
import 'package:intl/intl.dart';

class MyQRsPage extends StatefulWidget {
  @override
  _MyQRsPageState createState() => _MyQRsPageState();
}

class _MyQRsPageState extends State<MyQRsPage> {
  @override
  void initState() {
    _loadQRs();
    super.initState();
  }

  Future<void> _loadQRs() async {
    try {
      await QRManager.loadAllQRs();    
      setState(() {});
    } catch (e) {
      print("Error cargando QRs: $e");
    }
  }

  Future<void> _clearAllQRs() async {
    try {
      await QRManager.clearAllQRs(); // Use the class name here
      setState(() {});
    } catch (e) {
      print("Error al limpiar QRs: $e");
    }
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
              await _clearAllQRs();
            },
          ),
        ],
      ),
      body: QRManager.generatedQRs.isEmpty
          ? const Center(child: Text("No hay QRs generados."))
          : ListView.builder(
              itemCount: QRManager.generatedQRs.length,
              itemBuilder: (context, index) {
                final qr = QRManager.generatedQRs[index];
                return ListTile(
                  title: Text(qr.getAlias()),
                  subtitle: Text("ID: ${qr.getId()}"),
                  onTap: () => _showQR(qr),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadQRs,
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
        title: Text(
          alias,
          style: const TextStyle(fontSize: 18.0),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
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
    final url = qrparticular.getUrl();
    final formateador = DateFormat('yyyy-MM-dd HH:mm:ss');
    final creacionFormateada = formateador.format(qrparticular.getFechaCreacion());
    final escaneado = qrparticular.getVecesEscaneado();
    final ingresado = qrparticular.getVecesIngresado();
    String? usuariosPermitidos =
        await QRManager.getUsuariosPermitidos(qrparticular.getId());
    usuariosPermitidos ??= "todos"; // si es nulo asigna "todos", recomendado por compilador
    if (usuariosPermitidos == "")
    {
      usuariosPermitidos = "todos";
    }

    String? expiracionFormateada;
    // Comprueba si el QR es del tipo QRDinamico para acceder a la fecha de expiración
    if (qrparticular is QRdinamico) {
      final expiracion = qrparticular.getFechaExpiracion();
      expiracionFormateada = formateador.format(expiracion);
    }

    // Obtener información adicional
    final List<Map<String, dynamic>> informacion =
        await QRManager.obtenerInformacion(qrparticular.getId());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Información de $alias',
          textAlign: TextAlign.center,
          overflow: TextOverflow
              .ellipsis, // Agrega los puntos suspensivos si el texto es muy largo
          maxLines: 2, // Limita el texto a una sola línea
        ),
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
              Text('Alias: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(alias),
              SizedBox(height: 10),
              Text('Contenido del QR: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(url),
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
        QRManager.agregarNuevaInformacion(qr, nuevaInfo);
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
        QRManager.remove(qr);
        await QRManager.deleteQRFromFirestore(qr.getId());
        await QRManager.saveQRsToFile(QRManager.generatedQRs);
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
