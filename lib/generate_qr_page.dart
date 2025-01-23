import 'package:finalpoo_turina/logeo.dart';
import 'package:finalpoo_turina/qr_manager.dart';
import 'package:flutter/material.dart';
import 'my_qrs_page.dart'; //para mostrar los QR guardados
import 'qr_clases.dart';
import 'auth_service.dart';

class GenerateQRPage extends StatefulWidget {
  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isDynamic = false; // Si es un QR dinámico
  int? _expirationTime; // Tiempo de expiración en minutos
  DateTime? _expirationDate; // Fecha y hora de expiración
  final TextEditingController _controllertiempo = TextEditingController();
  String _ownerId = "local"; // O se podría reemplazar por la ID de Firebase
  final TextEditingController _controllerAlias = TextEditingController();

  final AuthService _authService = AuthService();
  bool _allowSpecificUsers = false;

  TextEditingController _controllerEmails = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserStatus(); // Llamamos al método que chequea si el usuario está logueado
  }

  // Función asincrónica para obtener el ID del usuario
  Future<void> _checkUserStatus() async {
    await _authService
        .initializeFirebase(); // Inicializa Firebase si aún no se ha hecho
    final user = await _authService.checkIfUserIsLoggedIn();

    if (user == null) {
      showError(
        context,
        "Se recomienda iniciar sesion para no perder sincronismo",
      );
      Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Log_page(),
                  ),
                );
    }

    setState(() {
      _ownerId = user?.uid ??
          "local"; // Si el usuario está logueado, usamos su UID; si no, usamos "local"
    });
  }

  // Guardar QR generado
  void _saveQR(String qrText) async {
    final newQR = _isDynamic
        ? QRdinamico(
            url: qrText,
            alias: _controllerAlias.text,
            fechaCreacion: DateTime.now(),
            owner: _ownerId,
            fechaExpiracion: _expirationDate!,
            id: "idvaciodinamico",
            vecesEscaneado: "0",
            vecesIngresado: "0",
          )
        : QREstatico(
            url: qrText,
            alias: _controllerAlias.text,
            fechaCreacion: DateTime.now(),
            owner: _ownerId,
            id: "idvacioestatico",
            vecesEscaneado: "0",
            vecesIngresado: "0",
          );

    // Agregar el QR generado a la lista de QR guardados
    if (newQR.getUrl() != '') {
      await QRManager.addGeneratedQR(newQR, _controllerEmails.text);
      // Imprimir en consola
      print("QR Guardado: ${newQR.toString()}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyQRsPage(),
        ),
      );
    }
  }

  String _generateQR() {
    print("el dueño es : ");
    print(_ownerId);
    if (_isDynamic && _expirationTime != null) {
      _expirationDate = DateTime.now().add(Duration(minutes: _expirationTime!));

      // Verificar que la fecha de expiración esté dentro de un rango razonable
      if (_expirationDate!.isBefore(DateTime.now())) {
        showError(context, "La fecha de expiración no puede ser en el pasado.");
        _controllertiempo.clear();
        return '';
      }
      return _controller.text;
    }

    return _controller
        .text; // Si no es dinámico, solo usamos el texto ingresado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generar QR')),
      body: SingleChildScrollView(
        // para desplazamiento
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo para el texto o URL
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Introduce URL para el QR',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Campo para el alias
              TextField(
                controller: _controllerAlias,
                decoration: InputDecoration(
                  hintText: 'Introduce un alias para este QR',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Opción para QR dinámico
              Row(
                children: [
                  Text("QR Dinámico: "),
                  Checkbox(
                    value: _isDynamic,
                    onChanged: (value) {
                      setState(() {
                        _isDynamic = value!;
                      });
                    },
                  ),
                ],
              ),

              // Campo para el tiempo de validez si es dinámico
              if (_isDynamic)
                TextField(
                  controller: _controllertiempo,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ingrese el tiempo de validez (minutos)',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _expirationTime = int.tryParse(value);
                    });

                    // Limitar valor
                    if (_expirationTime != null &&
                        _expirationTime! > 26280000000) {
                      _expirationTime = 26280000000; // Limita el valor
                      _controllertiempo.text =
                          _expirationTime.toString(); // Actualiza el campo
                      showError(context, "el limite son 50000 años");
                    }
                  },
                ),
              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Text("Permitir acceso a usuarios específicos: "),
                  ),
                  Checkbox(
                    value: _allowSpecificUsers,
                    onChanged: (value) {
                      setState(() {
                        _allowSpecificUsers = value!;
                      });
                    },
                  ),
                ],
              ),

              // Campo para ingresar correos electrónicos, visible solo si se habilita la opción anterior
              if (_allowSpecificUsers)
                TextField(
                  controller: _controllerEmails,
                  maxLines:
                      3, // Configura el campo para que tenga hasta 3 líneas
                  keyboardType: TextInputType
                      .multiline, // Habilita la entrada de varias líneas
                  decoration: InputDecoration(
                    hintText:
                        'Introduce correos electrónicos separados por coma',
                    border: OutlineInputBorder(),
                  ),
                ),
              SizedBox(height: 20),

              // Botón para guardar el QR
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.isEmpty ||
                      (_isDynamic &&
                          int.tryParse(_controllertiempo.text) == null) ||
                      _controllerAlias.text.isEmpty ||
                      _allowSpecificUsers && _controllerEmails.text.isEmpty) {
                    showError(context, 'Por favor, complete todos los campos.');
                  } else {
                    _saveQR(_generateQR()); // Guardamos el QR
                  }
                },
                child: Text('Guardar QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showError(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Atención"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    });
  }

  


}
