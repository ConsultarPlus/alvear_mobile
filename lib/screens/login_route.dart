import 'package:flutter/material.dart';
import 'lecturas_route.dart';
//Inicio Mis basuras

class LoginRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comuna Alvear - Login'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Ingresar'),
          onPressed: () {
            Navigator.push(
              context,
              //MaterialPageRoute(builder: (context) => SecondRoute()),
              MaterialPageRoute(builder: (context) => MyHomePage(title: 'Comuna Alvear - Lecturas')),
            );
          },
        ),
      ),
    );
  }
}

//Fin Mis basuras