import 'dart:io';  // Para trabajar con archivos
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';  // Para obtener la ruta del sistema de archivos

class MyQRsPage extends StatefulWidget {
  static List<String> generatedQRs = []; // Lista estática para almacenar los QR generados

  static void addGeneratedQR(String qrText) {
    generatedQRs.add(qrText); // Método para agregar un nuevo QR
    saveQRsToFile(); // Guardar cada vez que se agregue un QR
  }

  static Future<void> saveQRsToFile() async {
    final directory = await getTemporaryDirectory(); // Obtiene el directorio temporal
    final file = File('${directory.path}/generated_qrs.txt'); // Define el archivo

    // Convierte la lista a un formato de texto (por ejemplo, por saltos de línea)
    final text = generatedQRs.join('\n');
    
    await file.writeAsString(text); // Escribe la lista en el archivo
  }

  static Future<void> loadQRsFromFile() async {
    final directory = await getTemporaryDirectory(); // Obtiene el directorio temporal
    final file = File('${directory.path}/generated_qrs.txt'); // Define el archivo

    // Verifica si el archivo existe
    if (await file.exists()) {
      final text = await file.readAsString(); // Lee el archivo
      generatedQRs = text.split('\n'); // Convierte el texto de nuevo a lista
    }
  }

  @override
  _MyQRsPageState createState() => _MyQRsPageState();
}

class _MyQRsPageState extends State<MyQRsPage> {
  @override
  void initState() {
    super.initState();
    MyQRsPage.loadQRsFromFile(); // Cargar los QR guardados al iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis QR\'s')),
      body: ListView.builder(
        itemCount: MyQRsPage.generatedQRs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Acción al tocar un QR
              _showQR(MyQRsPage.generatedQRs[index]);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: ListTile(
                title: Text(MyQRsPage.generatedQRs[index]),
                tileColor: Colors.blue[50],
              ),
            ),
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
        content: Container(
          width: 200,
          height: 200,
          child: QrImageView(
            data: qrText,
            size: 200,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
