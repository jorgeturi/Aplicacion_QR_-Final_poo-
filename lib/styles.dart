import 'package:flutter/material.dart';


class AppColors {
  static const black = Color.fromARGB(255, 0, 0, 0);
  static const white = Color.fromARGB(255, 255, 255, 255);
  static const primary = Color.fromARGB(255, 42, 145, 255);
}

class AppButtonStyles {
  static final primary = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(AppColors.primary),
    foregroundColor: MaterialStateProperty.all(AppColors.white),
    side: MaterialStateProperty.all(BorderSide(color: Colors.black, width: 1)),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    padding: MaterialStateProperty.all(EdgeInsets.all(16)),
    overlayColor: MaterialStateProperty.all(Colors.grey),
     textStyle: MaterialStateProperty.all(
      TextStyle(
        fontFamily: 'Poppins', // Asegúrate de que la fuente Poppins esté agregada en pubspec.yaml
        fontWeight: FontWeight.bold,
        fontSize: 16, // Puedes ajustar el tamaño según tus necesidades
      ),
    ),
  );
}



class boton extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry margin;

  const boton({
    Key? key,
    required this.texto,
    required this.onPressed,
    this.margin = const EdgeInsets.all(4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: 350,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.primary, // Usa estilos centralizados
        child: Text(
          texto,
          //style: AppTextStyles.buttonText, // (Opcional) Si tienes un estilo de texto global
        ),
      ),
    );
  }
}