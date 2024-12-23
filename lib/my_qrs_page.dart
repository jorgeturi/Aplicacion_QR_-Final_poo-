import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
//TO DO

class MyQRsPage extends StatefulWidget {
  static List<String> generatedQRs = []; // Lista estática para almacenar los QR generados

  static void addGeneratedQR(String qrText) {
    generatedQRs.add(qrText); // Método para agregar un nuevo QR
  }

  @override
  _MyQRsPageState createState() => _MyQRsPageState();
}

class _MyQRsPageState extends State<MyQRsPage> {
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
              width: double.infinity,  // Establece un tamaño completo para el contenedor
              padding: EdgeInsets.all(10),
              child: ListTile(
                title: Text(MyQRsPage.generatedQRs[index]),
                tileColor: Colors.blue[50],  // Color de fondo para hacerlo más visible
              ),
            ),
          );
        },
      ),
    );
  }

  // Mostrar QR cuando se toca el nombre
  void _showQR(String qrText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR correspondiente'),
        content: Container(
          width: 200,   // Establece un tamaño para el contenedor del QR
          height: 200,  // Asegúrate de que el QR se muestre adecuadamente
          child: QrImageView(
            data: qrText,
            size: 200,   // También puedes ajustar el tamaño del QR aquí
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
