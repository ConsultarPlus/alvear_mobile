import 'dart:async';
import 'package:flutter/material.dart';
import 'lecturas_route.dart';
import 'package:alvear/models/inspector.dart';
import 'package:alvear/utils/database_helper.dart';
import 'package:alvear/utils/mensajes.dart';
import 'package:alvear/utils/urls.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginRoute extends StatefulWidget {

  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  Inspector _inspector = Inspector();
  List<Inspector> _inspectores =[];
  DatabaseHelper _dbHelper ;
  bool hayInspector = false;
  bool auth = false;
  final _inspectorDni = TextEditingController();
  final _inspectorClave = TextEditingController();

  @override
  void initState(){
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _buscaInspector();
  }

  _buscaInspector() async {
    // Verifica únicamente si hay un inspector loggeado o no
    List<Inspector> x = await _dbHelper.buscaInspectores();
    if (x.length > 0) {
      hayInspector = true;
      print("hay inspector ");
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Comuna Alvear - Lecturas')));
    } else {
      hayInspector = false;
      print("NO hay inspector");
    }
  }

  Future _verificaLog(Inspector _inspector) async {
    var url = urlInspector();
    var ok = true;
    var jsonData;
    auth = false;
    try {
      jsonData = await http.get(url).timeout(const Duration(seconds: 3));
    } on TimeoutException catch (e) {
      mensajeError(context, 'Error', 'Tiempo de espera agotado');
      ok = false;
    } on Error catch (e) {
      mensajeError(context, 'Error', 'Ocurrió un error, intente más tarde');
      ok = false;
    }
    if (ok == true) {
      if (jsonData.statusCode == 200) {
        List inspectores = json.decode(jsonData.body);
        List<Inspector> listaInspectores = inspectores.map((map) =>
            Inspector.fromJson(map)).toList();
        for (var inspector in listaInspectores) {
          Inspector _inspectorObject = Inspector(
            id: inspector.id,
            dni: inspector.dni,
            nombre: inspector.nombre,
            e_mail: inspector.e_mail,
            clave_app: inspector.clave_app,
          );
          // Grabo en la base de datos al inspector loggeado
          if (inspector.dni == _inspector.dni) {
            if (inspector.clave_app == _inspector.clave_app) {
              await _dbHelper.insertInspector(_inspectorObject);
              auth = true;
              break;
            }
          }
        }
        if (auth == true) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  MyHomePage(title: 'Comuna Alvear - Lecturas')));
        }
      }
      if (auth != true) {
        mensajeError(context, 'Error', 'DNI o pin incorrecto');
        print(
            "El inspector o la clave no coinciden con los inspectores activos");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comuna Alvear - LogIn'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _inspectorDni,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'D.N.I.',
                  icon: const Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: const Icon(Icons.account_box),
                  )),
              onChanged: (val) {
                setState(() {
                  _inspector.dni = int.parse(val);
                });
              },
            ),
            TextFormField(
              controller: _inspectorClave,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'PIN',
                  icon: const Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: const Icon(Icons.lock),
                  )),
              onChanged: (val) {
                setState(() {
                  _inspector.clave_app = val;
                  });
                },
              obscureText: true,
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              child: RaisedButton(
                child: Text('Ingresar'),
                onPressed: () {
                    _verificaLog(_inspector);
                },
              ),
            )
        ]),
      ),
    );
  }

}
