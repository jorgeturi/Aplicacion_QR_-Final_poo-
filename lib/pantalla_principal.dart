import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'styles.dart';
import 'generate_qr_page.dart';
import 'my_qrs_page.dart';
import 'boton_flotante.dart';
import 'logeo.dart';

/*
  Esta pantalla principal (pantalla_principal) actúa como el menú de inicio de la aplicación, 
  ofreciendo acceso a las principales funcionalidades mediante botones y animaciones. 
*/ 

class pantalla_principal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          opciones(),
        ],
      ),
      ),
      floatingActionButton: boton_flotante(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class opciones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(  // Usamos Center para centrar todo el contenido
      child: Column(
        children: <Widget>[
          SizedBox(height: 50),

          Lottie.asset(
            'imagenes/main/qr_animacion.json',
            width: 200,
            height: 200,
            alignment: Alignment.center,  // Alineamos la animación al centro
            repeat: true,
            reverse: true,
            animate: true,
          ),
          // "Mi cuenta"
          IconButtonWithText(
            texto: 'Mi cuenta',
            icono: Icons.person,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Log_page()), 
              );
            },
          ),
          SizedBox(height: 20),
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
          SizedBox(height: 80),
        ],
      ),
    );
  }
}

