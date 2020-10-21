import 'package:flutter/material.dart';
import './screens/login_route.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comuna Alvear - Lecturas',
      theme: ThemeData(
        primaryColor: Colors.green.shade800,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginRoute(),
    );
  }
}