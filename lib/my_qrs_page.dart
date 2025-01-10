import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:finalpoo_turina/qr_storage.dart';

class MyQRsPage extends StatefulWidget {
  static List<String> generatedQRs = [];

  // Método para agregar QR a la lista de QRs generados
  static void addGeneratedQR(String qrText) {
    // Añadir el nuevo QR solo si no está ya en la lista
    if (!generatedQRs.contains(qrText)) {
      generatedQRs.add(qrText);
      QRStorage.saveQRsToFile(generatedQRs); // Guarda el nuevo QR en el archivo
      QRStorage.addGeneratedQRToFirestore(qrText); // Guarda el nuevo QR en Firestore
    }
  }

  // Método asíncrono para cargar todos los QRs desde Firestore y archivos
  static Future<void> loadAllQRs() async {
    if (generatedQRs.isEmpty) { // Solo cargamos si la lista está vacía
      final fileQRs = <String>[];
      await QRStorage.loadQRsFromFile(fileQRs); // Cargar QRs desde el archivo
      final firestoreQRs = await QRStorage.loadQRsFromFirestore(); // Cargar QRs desde Firestore
      // Unir ambas listas de forma correcta sin duplicar elementos
      generatedQRs = [...fileQRs, ...firestoreQRs]..toSet().toList();
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
        title: Text('Mis QR\'s'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                MyQRsPage.generatedQRs.clear();
                QRStorage.saveQRsToFile(MyQRsPage.generatedQRs);
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: MyQRsPage.generatedQRs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(MyQRsPage.generatedQRs[index]),
            onTap: () => _showQR(MyQRsPage.generatedQRs[index]),
          );
        },
      ),
    );
  }

  void _showQR(String qrText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR correspondiente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(data: qrText, size: 300),
            ElevatedButton(
              onPressed: () async {
                MyQRsPage.generatedQRs.remove(qrText);
                await QRStorage.deleteQRFromFirestore(qrText);
                await QRStorage.saveQRsToFile(MyQRsPage.generatedQRs);
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Eliminar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
