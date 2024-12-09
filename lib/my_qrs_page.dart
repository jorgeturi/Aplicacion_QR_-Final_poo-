import 'package:flutter/material.dart';

class MyQRsPage extends StatelessWidget {
  final List<String> generatedQRs = [
    "QR 1",
    "QR 2",
    "QR 3",
    "QR 4",
  ]; // Aquí puedes agregar más QR generados

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis QR\'s')),
      body: ListView.builder(
        itemCount: generatedQRs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(generatedQRs[index]),
            onTap: () {
              // Acción al tocar un QR (por ejemplo, ver detalles)
            },
          );
        },
      ),
    );
  }
}
