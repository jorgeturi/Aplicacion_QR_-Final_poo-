import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';  // Aquí importas tu servicio de autenticación
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';


class Log_page extends StatefulWidget {
  @override
  _Log_pageState createState() => _Log_pageState();
}

class _Log_pageState extends State<Log_page> {
  String connectionStatus = 'Comprobando conexión a Firebase...';
  String authStatus = 'No autenticado';
  final AuthService _authService = AuthService(); // Instanciamos el AuthService
  bool useBiometrics = false; // Variable para almacenar si se debe usar biometría
  final BiometricAuthService biometricAuthService = BiometricAuthService(); // Instanciamos el servicio de biometría

  // Método para cargar el estado de "Usar biometría" desde SharedPreferences
  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      useBiometrics = prefs.getBool('useBiometrics') ?? false;  // Cargar valor persistido o false por defecto
    });
  }

  // Método para guardar el estado de "Usar biometría" en SharedPreferences
  Future<void> _saveBiometricPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('useBiometrics', value);
  }

  // Método para manejar el checkbox de "Usar biometría"
  void _onBiometricToggle(bool? value) {
    setState(() {
      useBiometrics = value!;
    });

    // Guardar el estado de la opción en SharedPreferences
    _saveBiometricPreference(useBiometrics);

    // Si se habilita la biometría, intentar desbloquear la app
    if (useBiometrics) {
      _authenticateBiometricsOnStart();
    }
  }

  // Llamamos al servicio de biometría
  Future<void> _authenticateBiometricsOnStart() async {
    if (kIsWeb) {
      return;
    }
    String result = await biometricAuthService.authenticateBiometrics();
    setState(() {
      authStatus = result;
    });
  }

  

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
    _checkIfUserIsLoggedIn();
    _loadBiometricPreference();  // Cargar la preferencia de biometría
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              connectionStatus,
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              authStatus,
              style: TextStyle(fontSize: 18, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: useBiometrics,
                  onChanged: _onBiometricToggle,
                ),
                Text('Usar biometría'),
              ],
            ),
            SizedBox(height: 20),
            if (authStatus == 'No autenticado')
              ElevatedButton(
                onPressed: signInWithGoogle,
                child: Text('Iniciar Sesión con Google'),
              ),
            SizedBox(height: 20),
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





class BiometricAuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<String> authenticateBiometrics() async {
    // Verifica si la plataforma es web y omite la autenticación biométrica
    if (kIsWeb) {
      return "Autenticación biométrica no disponible en la web";
    }

    try {
      bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      if (!canAuthenticateWithBiometrics) {
        return 'Biometría no disponible en este dispositivo';
      }

      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return 'No se ha configurado ninguna biometría en este dispositivo';
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Escanea tu huella o cara para desbloquear la app',
        options: AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        return 'App desbloqueada con biometría';
      } else {
        return 'Autenticación fallida';
      }
    } catch (e) {
      return "Error de autenticación biométrica: $e";
    }
  }


Future<bool> loadBiometricPreference() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('useBiometrics') ?? false; // Valor predeterminado: false
}



}