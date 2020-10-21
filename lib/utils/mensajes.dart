import 'package:flutter/material.dart';

mensajeError(BuildContext context, String titulo, String mensaje) {
  showAlertDialog(context, 'error', titulo, mensaje);
}

mensajeAlerta(BuildContext context, String titulo, String mensaje) {
  showAlertDialog(context, 'alerta', titulo, mensaje);
}

mensajeExito(BuildContext context, String titulo, String mensaje) {
  showAlertDialog(context, 'exito', titulo, mensaje);
}

mensajeNormal(BuildContext context, String titulo, String mensaje) {
  showAlertDialog(context, 'normal', titulo, mensaje);
}

showAlertDialog(BuildContext context, String tipo, String titulo, String mensaje) {

  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  var colorto;

  switch(tipo) {
    case 'error':{
      colorto = Colors.redAccent;
    }
    break;
    case 'alerta':{
      colorto = Colors.amberAccent;
    }
    break;
    case 'exito':{
      colorto = Colors.greenAccent;
    }
    break;
    default: {
      colorto = Colors.lightBlueAccent;
    }
      break;
  }
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(titulo),
    content: Text(mensaje),
    backgroundColor: colorto,
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}