import 'package:flutter/material.dart';
import 'screens/pharmacy_screen.dart';

void main() {
  runApp(NobetciEczaneApp());
}

class NobetciEczaneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nöbetçi Eczaneler',
      theme: ThemeData(primarySwatch: Colors.red),
      home: PharmacyScreen(),
    );
  }
}
