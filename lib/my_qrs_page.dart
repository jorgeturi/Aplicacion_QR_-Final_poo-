import 'dart:math';

import 'package:finalpoo_turina/styles.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:finalpoo_turina/qr_storage.dart';
import 'package:flutter/foundation.dart'; // Para el manejo de la lista
import 'qr_clases.dart';
import 'package:intl/intl.dart';


class MyQRsPage extends StatefulWidget{
  static List<QREstatico> generatedQRs = [];  // Lista de objetos QR

  // Método para agregar un QR a la lista de QRs generados
  static Future<void> addGeneratedQR(QREstatico qr, String users) async {
  if (!generatedQRs.any((existingQR) => existingQR.id == qr.id)) {
    await QRStorage.addGeneratedQRToFirestore(qr, users);  // Esperamos que Firestore termine
    generatedQRs.add(qr);
    QRStorage.saveQRsToFile(generatedQRs);  // Guardamos el nuevo QR en el archivo
  }
}
  

  // Método asíncrono para cargar todos los QRs desde Firestore y archivos
 static Future<void> loadAllQRs() async {
  print("Cargando todos los QRs..."); // Mensaje de depuración

  final fileQRs = <QREstatico>[];  // Lista para almacenar los QRs desde el archivo
  final firestoreQRs = await QRStorage.loadQRsFromFirestore(); // Cargar QRs desde Firestore

  await QRStorage.loadQRsFromFile(fileQRs); // Cargar QRs desde el archivo

  // Usar un Map para asegurarse de que los QRs sean únicos por su ID
  final allQRsMap = <String, QREstatico>{};

  for (var qr in [...fileQRs, ...firestoreQRs]) {
    if (qr != null) {
      allQRsMap[qr.getId()] = qr;  // Insertar el QR en el mapa, sobrescribiendo duplicados por ID
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
        print("Botón de actualización presionado");
        await MyQRsPage.loadAllQRs();
        print("Después de cargar los QRs...");
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
      title: Text(alias, style: const TextStyle(fontSize: 18.0), textAlign: TextAlign.center),
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
              _showQRInfo(qrparticular); // Abre el nuevo popup con información
            },
            child: const Text('Información'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              MyQRsPage.generatedQRs.remove(qrparticular);
              await QRStorage.deleteQRFromFirestore(qrparticular.getId());
              await QRStorage.saveQRsToFile(MyQRsPage.generatedQRs);
              Navigator.of(context).pop();
              setState(() {});
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

void _showQRInfo(QREstatico qrparticular) {
  final alias = qrparticular.getAlias();
  final url = qrparticular.url;
  final formateador = DateFormat('yyyy-MM-dd HH:mm:ss');
  final creacionFormateada = formateador.format(qrparticular.fechaCreacion);

  String? expiracionFormateada;
  // Comprueba si el QR es del tipo QRDinamico para acceder a la fecha de expiración
  if (qrparticular is QRdinamico) {
    final expiracion = qrparticular.fechaExpiracion;
    expiracionFormateada = formateador.format(expiracion);
  }


  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Información de $alias', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alias: $alias'),
          Text('Contenido del QR: $url'),
          Text('fecha creacion: $creacionFormateada'),
          if(qrparticular is QRdinamico)
            Text('fecha expiracion: $expiracionFormateada'),
          
          const SizedBox(height: 10),
          Text(
            'Este código QR es usado para XYZ...',
            style: const TextStyle(color: Colors.grey),
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



}
