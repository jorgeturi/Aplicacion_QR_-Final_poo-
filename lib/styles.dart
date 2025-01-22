import 'package:flutter/material.dart';


class AppColors {
  static const black = Color.fromARGB(255, 0, 0, 0);
  static const white = Color.fromARGB(255, 255, 255, 255);
  static const primary = Color.fromARGB(255, 42, 145, 255);
}

class AppButtonStyles {
  static final primary = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppColors.primary),
    foregroundColor: WidgetStateProperty.all(AppColors.white),
    //side: WidgetStateProperty.all(BorderSide(color: Colors.black, width: 1)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    padding: WidgetStateProperty.all(EdgeInsets.all(16)),
    overlayColor: WidgetStateProperty.all(const Color.fromARGB(255, 15, 97, 185)),
     textStyle: WidgetStateProperty.all(
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
      width: 300,
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



ThemeData appTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primary, // Color del botón
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Color de fondo
        foregroundColor: AppColors.white, //texto
        padding: EdgeInsets.all(16), // Relleno interno del botón
        shape: RoundedRectangleBorder( // Forma del botón
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4, // Sombra del botón
        textStyle: TextStyle( // Estilo del texto
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
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
        backgroundColor: Color.fromARGB(255, 247, 239, 239),
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
            style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 34, 25, 163),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
