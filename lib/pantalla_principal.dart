import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'styles.dart'; // Asegúrate de que Boton esté en este archivo
import 'generate_qr_page.dart';
import 'my_qrs_page.dart';
import 'boton_flotante.dart';
import 'logeo.dart';

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
          top: 20,
          child: Lottie.asset(
            'imagenes/main/qr_animacion.json',
            width: 200,
            height: 200,
            alignment: Alignment.bottomRight,
            repeat: true,
            reverse: true,
            animate: true,
          ),
        ),
        
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Usamos IconButtonWithText para la "Mi cuenta"
            IconButtonWithText(
              texto: 'Mi cuenta',
              icono: Icons.person,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Log_page()), // Asegúrate de importar la página LoginPage
                );
              },
            ),

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


class IconButtonWithText extends StatelessWidget {
  final String texto;
  final IconData icono;
  final VoidCallback onPressed;

  IconButtonWithText({
    required this.texto,
    required this.icono,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        
        

        minimumSize: Size(80, 80), // Dimensiones cuadradas del botón
      ),
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icono, size: 40, color: const Color.fromARGB(255, 0, 0, 0)),
          SizedBox(height: 8),
          Text(
            texto,
            style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 34, 25, 163), fontFamily: 'Poppins',fontWeight: FontWeight.bold),
          
          ),
        ],
      ),
    );
  }
}