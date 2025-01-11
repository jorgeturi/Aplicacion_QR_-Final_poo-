import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:finalpoo_turina/qr_storage.dart';
import 'package:flutter/foundation.dart';  // para el manejo de la lista


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
  print("Cargando todos los QRs...");  // Mensaje de depuración
  
  final fileQRs = <String>[];
  await QRStorage.loadQRsFromFile(fileQRs); // Cargar QRs desde el archivo
  final firestoreQRs = await QRStorage.loadQRsFromFirestore(); // Cargar QRs desde Firestore
  final allQRs = [...fileQRs, ...firestoreQRs]..removeWhere((qr) => qr == null);

  // Comparar los datos nuevos con los existentes para evitar duplicados
  final newQRs = allQRs.toSet().toList();
  
  // Si los datos nuevos son distintos a los actuales, actualizar la lista
  if (!listEquals(newQRs, generatedQRs)) {
    generatedQRs = newQRs;
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
        title: Text('Mis QR\'s'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
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
          ? Center(child: Text("No hay QRs generados."))
          : ListView.builder(
              itemCount: MyQRsPage.generatedQRs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(MyQRsPage.generatedQRs[index]),
                  onTap: () => _showQR(MyQRsPage.generatedQRs[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Agregar debug print para verificar si se presiona el botón
          print("Botón de actualización presionado");
          
          // Llamar al método para cargar todos los QRs nuevamente
          await MyQRsPage.loadAllQRs();
          
          // Asegurarse de que setState esté llamándose para actualizar la UI
          print("Después de cargar los QRs...");
          setState(() {});
        },
        child: Icon(Icons.refresh), // Icono de actualización
        tooltip: 'Actualizar QR\'s',
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
            Container(
              width: 300,
              height: 300,
              child: QrImageView(data: qrText),
            ),
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
