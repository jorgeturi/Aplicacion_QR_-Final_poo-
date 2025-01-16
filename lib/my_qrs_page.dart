import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:finalpoo_turina/qr_storage.dart';
import 'package:flutter/foundation.dart'; // Para el manejo de la lista

class MyQRsPage extends StatefulWidget {
  static List<String> generatedQRs = [];

  // Método para agregar QR a la lista de QRs generados
  static void addGeneratedQR(String qrText) {
    if (!generatedQRs.contains(qrText)) {
      generatedQRs.add(qrText);
      QRStorage.saveQRsToFile(generatedQRs); // Guarda el nuevo QR en el archivo
      QRStorage.addGeneratedQRToFirestore(qrText); // Guarda el nuevo QR en Firestore
    }
  }

  // Método asíncrono para cargar todos los QRs desde Firestore y archivos
  static Future<void> loadAllQRs() async {
    print("Cargando todos los QRs..."); // Mensaje de depuración

    final fileQRs = <String>[];
    await QRStorage.loadQRsFromFile(fileQRs); // Cargar QRs desde el archivo
    final firestoreQRs = await QRStorage.loadQRsFromFirestore(); // Cargar QRs desde Firestore
    final allQRs = [...fileQRs, ...firestoreQRs]
        .where((qr) => qr != null)
        .toSet()
        .toList();

    // Si los datos nuevos son distintos a los actuales, actualizar la lista
    if (!listEquals(allQRs, generatedQRs)) {
      generatedQRs = allQRs;
      print("QRs cargados y actualizados: ${generatedQRs.length}");
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
              final qrText = MyQRsPage.generatedQRs[index];
              final parts = qrText.split('|'); // Divide el texto por el separador '|'

              // Verifica si hay al menos dos partes para acceder al alias
              final alias = (parts.length > 1) ? parts[1] : "Alias no disponible";

              return ListTile(
                title: Text(alias), // Muestra solo el alias
                onTap: () => _showQR(qrText), // Pasa el texto completo del QR al mostrarlo
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
