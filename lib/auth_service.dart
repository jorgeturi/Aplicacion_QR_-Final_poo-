import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' show DefaultFirebaseOptions;
import 'package:flutter/foundation.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inicializar Firebase según la plataforma
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Verificar si el usuario ya está autenticado
  Future<User?> checkIfUserIsLoggedIn() async {
    return _auth.currentUser;
  }

  // Iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;

      // En la web intentamos el inicio de sesión silencioso
      if (kIsWeb) {
        googleUser = await _googleSignIn.signInSilently();  // Evita la ventana emergente
      } else {
        googleUser = await _googleSignIn.signIn();  // Usamos el inicio normal en móviles
      }

      if (googleUser == null) {
        return null; // Usuario cancela el inicio de sesión
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autenticamos con Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
