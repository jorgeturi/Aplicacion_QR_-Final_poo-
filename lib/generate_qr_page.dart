import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'my_qrs_page.dart'; // Importamos MyQRsPage para mostrar los QR guardados


class GenerateQRPage extends StatefulWidget {
  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final TextEditingController _controller = TextEditingController();
  bool isDynamic = false; // Si es un QR dinámico
  int? expirationTime; // Tiempo de expiración en minutos
  DateTime? expirationDate; // Fecha y hora de expiración

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

String _generateDynamicQR() {
  if (isDynamic && expirationTime != null) {
    expirationDate = DateTime.now().add(Duration(minutes: expirationTime!));
    return "${_controller.text}|${expirationDate!.toIso8601String()}";
  }
  return _controller.text; // Si no es dinámico, solo usamos el texto ingresado
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
            Row(
              children: [
                Text("QR Dinámico: "),
                Checkbox(
                  value: isDynamic,
                  onChanged: (value) {
                    setState(() {
                      isDynamic = value!;
                    });
                  },
                ),
              ],
            ),
            if (isDynamic)
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ingrese el tiempo de validez (minutos)',
                ),
                onChanged: (value) {
                  setState(() {
                    expirationTime = int.tryParse(value);
                  });
                },
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
                    data: _generateDynamicQR(),
                    size: 200,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _controller.text.isEmpty
                  ? null
                  : () {
                      _saveQR(_generateDynamicQR()); // Guardamos el QR
                    },
              child: Text('Guardar QR'),
            ),
          ],
        ),
      ),
    );
  }
}
