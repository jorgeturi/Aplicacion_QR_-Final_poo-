import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart'; 

class Log_page extends StatefulWidget {
  @override
  _Log_pageState createState() => _Log_pageState();
}

class _Log_pageState extends State<Log_page> {
  String connectionStatus = 'Comprobando conexión a Firebase...';
  String authStatus = 'No autenticado';
  final AuthService _authService = AuthService(); // Instanciamos el AuthService

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
    _checkIfUserIsLoggedIn();
  }

  // Verificar el estado de Firebase
  void _checkFirebaseStatus() async {
    try {
      await _authService.initializeFirebase();
      setState(() {
        connectionStatus = 'Conectado a la nube. Podés usar la app';
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Error al verificar Firebase: $e';
      });
    }
  }

  // Verificar si el usuario ya está autenticado
  void _checkIfUserIsLoggedIn() async {
    User? user = await _authService.checkIfUserIsLoggedIn();
    if (user != null) {
      setState(() {
        authStatus = 'Autenticado como: ${user.displayName}';
      });
    } else {
      setState(() {
        authStatus = 'No autenticado';
      });
    }
  }

  // Método para autenticar con Google
  Future<void> signInWithGoogle() async {
    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      setState(() {
        authStatus = 'Autenticado como: ${user.displayName}';
      });
    } else {
      setState(() {
        authStatus = 'Inicio de sesión cancelado por el usuario';
      });
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await _authService.signOut();
    setState(() {
      authStatus = 'No autenticado';
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Iniciar Sesión')),
    body: Center( // Center se usa para centrar todo el contenido dentro del cuerpo
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centra todo el contenido verticalmente
        crossAxisAlignment: CrossAxisAlignment.center, // Centra todo el contenido horizontalmente
        children: [
          // Texto con el estado de la conexión
          Text(
            connectionStatus, // Mostrar el estado de la conexión
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.center, // Asegura que el texto esté centrado
          ),
          SizedBox(height: 20),
          
          // Texto con el estado de la autenticación
          Text(
            authStatus, // Mostrar el estado de la autenticación
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),
            textAlign: TextAlign.center, // Asegura que el texto esté centrado
          ),
          SizedBox(height: 20),
          
          // Si no está autenticado, mostrar el botón de iniciar sesión
          if (authStatus == 'No autenticado')
            ElevatedButton(
              onPressed: signInWithGoogle,
              child: Text('Iniciar Sesión con Google'),
            ),
          SizedBox(height: 20),
          
          // Si está autenticado, mostrar el botón de cerrar sesión
          if (authStatus != 'No autenticado')
            ElevatedButton(
              onPressed: signOut,
              child: Text('Cerrar sesión'),
            ),
        ],
      ),
    ),
  );
}



}
