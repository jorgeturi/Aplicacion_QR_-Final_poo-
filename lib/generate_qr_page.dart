import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateQRPage extends StatefulWidget {
  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final TextEditingController _controller = TextEditingController();
  
  // Función para guardar el QR
  Future<void> _saveQR(String qrText) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedQRs = prefs.getStringList('savedQRs') ?? [];
    savedQRs.add(qrText);
    await prefs.setStringList('savedQRs', savedQRs);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR Guardado')));
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
                fillColor: Color(0xFF123456),
                filled: true,
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
            // Mostrar el QR si el texto no está vacío
            _controller.text.isEmpty
                ? Container()
                : QrImageView(
                    data: _controller.text,  // Pasar el texto directamente al `QrImage`
                    size: 200,
                  ),
            SizedBox(height: 20),
            // Botón para guardar el QR
            ElevatedButton(
              onPressed: _controller.text.isEmpty
                  ? null  // Deshabilitar el botón si el campo está vacío
                  : () {
                      _saveQR(_controller.text);  // Guardar el QR
                    },
              child: Text('Guardar QR'),
            ),
          ],
        ),
      ),
    );
  }
}
