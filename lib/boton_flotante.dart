import 'package:flutter/material.dart';
import 'qr_scanner_page.dart';
import 'styles.dart';

class boton_flotante extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QrScannerPage()),
        );
      },
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      child: Icon(
        Icons.qr_code,
        size: 40.0,
      ),
    );
  }
}