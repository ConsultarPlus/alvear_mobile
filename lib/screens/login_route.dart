import 'package:flutter/material.dart';
import 'lecturas_route.dart';
import 'package:alvear/models/medicion.dart';
import 'package:alvear/utils/database_helper.dart';
import 'package:alvear/Config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//Inicio Mis basuras

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
          //MaterialPageRoute(builder: (context) => SecondRoute()),
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Comuna Alvear - Lecturas')));
    } else {
      hayInspector = false;
      print("NO hay inspector");
    }
  }

  Future _verificaLog(Inspector _inspector) async {
    var url = 'http://10.0.2.2:8000/inspecciones/inspectores_json/';
    // var url = 'http://190.193.200.120:88/expediente/devuelve_json/';
    var jsonData = await http.get(url);
    if (jsonData.statusCode == 200) {
      List inspectores = json.decode(jsonData.body);
      List<Inspector> listaInspectores = inspectores.map((map) => Inspector.fromJson(map)).toList();
      for (var inspector in listaInspectores) {
        Inspector _inspectorObject = Inspector(
            id: inspector.id,
            dni: inspector.dni,
            nombre: inspector.nombre,
            e_mail: inspector.e_mail,
            clave_app: inspector.clave_app,
        );
        // Grabo en la base de datos al inspector loggeado
        if (inspector.dni == _inspector.dni){
          if (inspector.clave_app == _inspector.clave_app){
            await _dbHelper.insertInspector(_inspectorObject);
            auth = true;
            break;
          }
        }
      }
      if (auth==true){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MyHomePage(title: 'Comuna Alvear - Lecturas')));
      };
    }
    if (auth==false){
      print("El inspector o la clave no coinciden con los inspectores activos");
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

//Fin Mis basuras