import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
          return ListTile(
            title: Text(MyQRsPage.generatedQRs[index]),
            onTap: () {
              // Acción al tocar un QR
              _showQR(MyQRsPage.generatedQRs[index]);
            },
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
        content: QrImageView(
          data: qrText,
          size: 200,
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
