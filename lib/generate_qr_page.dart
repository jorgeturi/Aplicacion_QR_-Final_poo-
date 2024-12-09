import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'my_qrs_page.dart'; // Importamos MyQRsPage para mostrar los QR guardados

class GenerateQRPage extends StatefulWidget {
  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final TextEditingController _controller = TextEditingController();

  // Guardar QR generado
  void _saveQR(String qrText) {
    MyQRsPage.addGeneratedQR(qrText); // Llamamos al método para agregar el QR a la lista global
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyQRsPage(), // Llamamos la página de listado
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generar QR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Introduce el texto o URL para el QR',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: Text('Generar QR'),
            ),
            SizedBox(height: 20),
            _controller.text.isEmpty
                ? Container()
                : QrImageView(
                    data: _controller.text,
                    size: 200,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _controller.text.isEmpty
                  ? null
                  : () {
                      _saveQR(_controller.text); // Guardamos el QR
                    },
              child: Text('Guardar QR'),
            ),
          ],
        ),
      ),
    );
  }
}
