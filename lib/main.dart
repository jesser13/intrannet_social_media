import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 🔥 initialise Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intranet Social',
      home: Scaffold(
        appBar: AppBar(title: Text('Bienvenue')),
        body: Center(child: Text('Firebase connecté !')),
      ),
    );
  }
}
