import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'styles.dart'; // Asegúrate de que Boton esté en este archivo
import 'generate_qr_page.dart';
import 'my_qrs_page.dart';
import 'boton_flotante.dart';

class pantalla_principal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inicio")),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          opciones(),
        ],
      ),
      floatingActionButton: boton_flotante(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class opciones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top: 0,
          child: Lottie.asset(
            'imagenes/main/qr_animacion.json',
            width: 200,
            height: 200,
            repeat: true,
            reverse: true,
            animate: true,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            boton(
              texto: 'Generar QR',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GenerateQRPage()),
                );
              },
            ),
            boton(
              texto: 'Mis QR',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyQRsPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}