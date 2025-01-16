import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:finalpoo_turina/qr_storage.dart';
import 'package:flutter/foundation.dart'; // Para el manejo de la lista
import 'qr_clases.dart';

class MyQRsPage extends StatefulWidget{
  static List<QREstatico> generatedQRs = [];  // Lista de objetos QR

  // Método para agregar un QR a la lista de QRs generados
  static Future<void> addGeneratedQR(QREstatico qr) async {
  if (!generatedQRs.any((existingQR) => existingQR.id == qr.id)) {
    await QRStorage.addGeneratedQRToFirestore(qr);  // Esperamos que Firestore termine
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

    final allQRs = [...fileQRs, ...firestoreQRs]
        .where((qr) => qr != null)
        .toSet()
        .toList();

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

              // Generamos la URL con el id
              final qrUrl = "https://finalpoo-turinajorge.web.app/validador/?qr=$id";

              return ListTile(
                title: Text(alias), // Muestra el alias
                subtitle: Text("ID: $id"), // Muestra el ID
                onTap: () => _showQR(qrUrl), // Pasa la URL generada al mostrarlo
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
    ),
  );
}

  void _showQR(String qrText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR correspondiente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              height: 300,
              child: QrImageView(data: qrText),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                MyQRsPage.generatedQRs.remove(qrText);
                await QRStorage.deleteQRFromFirestore(qrText);
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
}
