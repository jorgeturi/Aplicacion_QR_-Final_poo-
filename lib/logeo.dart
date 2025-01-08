import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Log_page extends StatefulWidget {
  @override
  _Log_pageState createState() => _Log_pageState();
}

class _Log_pageState extends State<Log_page> {
  String connectionStatus = 'Comprobando conexión a Firebase...';
  String authStatus = 'No autenticado';

  @override
  void initState() {
    super.initState();
    checkFirebaseStatus();
  }

  // Método para verificar si Firebase ya está inicializado
  void checkFirebaseStatus() {
    try {
      setState(() {
        connectionStatus = 'Firebase está inicializado y funcionando';
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Error al verificar Firebase: $e';
      });
    }
  }

  // Método para autenticar con Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() {
          authStatus = 'Inicio de sesión cancelado por el usuario';
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() {
        authStatus =
            'Autenticado como: ${FirebaseAuth.instance.currentUser?.displayName}';
      });
    } catch (e) {
      setState(() {
        authStatus = 'Error al iniciar sesión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            connectionStatus, // Mostrar el estado de la conexión
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            authStatus, // Mostrar el estado de la autenticación
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: signInWithGoogle,
            child: Text('Iniciar Sesión con Google'),
          ),
        ],
      ),
    );
  }
}