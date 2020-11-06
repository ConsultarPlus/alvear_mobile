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
  // Navigator.of(context).pop();
  var colorto;
  var colorto_texto;
  switch(tipo) {
    case 'error':{
      colorto = Colors.red[100];
      colorto_texto = Colors.red[900];
    }
    break;
    case 'alerta':{
      colorto = Colors.yellow[100];
      colorto_texto = Colors.yellow[900];
    }
    break;
    case 'exito':{
      colorto = Colors.green[100];
      colorto_texto = Colors.green[900];
    }
    break;
    default: {
      colorto = Colors.lightBlue[100];
      colorto_texto = Colors.lightBlue[900];
    }
    break;
  }
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    textColor: colorto_texto,
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(titulo,
                style: TextStyle(fontStyle: FontStyle.italic,
                                 color: colorto_texto),
                ),
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


procesando(BuildContext context, String texto) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: new Row(
          // mainAxisSize: MainAxisSize.min,
          children: [
            new SizedBox(
              child: CircularProgressIndicator(),
              height: 30.0,
              width: 20.0,
            ),
            new Text('  ' + texto),
          ],
        ),
      );
    },
  );
}

