import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MytestPage extends StatefulWidget {
  @override
  _MytestPageState createState() => _MytestPageState();
}

class _MytestPageState extends State<MytestPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '929827470228-tt162jkolsa79a09u20l4h5lj6ve1kfg.apps.googleusercontent.com', // Tu ID de cliente web
  );

  // Variable para el estado del usuario.
  User? _user;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _user = account != null ? FirebaseAuth.instance.currentUser : null;
      });
    });
    _googleSignIn.signInSilently();
  }

  // Método para iniciar sesión con Google
  Future<User?> _signInWithGoogle() async {
    try {
      // Realiza la autenticación con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Si el usuario cancela el inicio de sesión
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autenticación en Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      return user;
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MytestPage - Autenticación con Google"),
      ),
      body: Center(
        child: _user == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      await _signInWithGoogle();
                    },
                    child: Text("Iniciar sesión con Google"),
                  ),
                  Text("No estás autenticado."),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Bienvenido, ${_user!.displayName}"),
                  ElevatedButton(
                    onPressed: () async {
                      await _signOut();
                    },
                    child: Text("Cerrar sesión"),
                  ),
                ],
              ),
      ),
    );
  }
}
