import 'dart:async';
// import 'dart:html';
import 'package:flutter/material.dart';
import 'login_route.dart';
import 'package:alvear/models/inspector.dart';
import 'package:alvear/models/medicion.dart';
import 'package:alvear/utils/database_helper.dart';
import 'package:alvear/utils/mensajes.dart';
import 'package:alvear/utils/urls.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alvear/Config.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


  class _MyHomePageState extends State<MyHomePage> {

  Medicion _medicion = Medicion();
  List<Medicion> _mediciones =[];
  DatabaseHelper _dbHelper ;
  final _formKey = GlobalKey<FormState>();
  final _ctrlMedidor = TextEditingController();
  final _ctrlLectura = TextEditingController();
  final _ctrlDomicilio = TextEditingController();
  bool _mostrarForm = false;
  var inspector_nombre;
  var inspector_id;

  @override
  void initState(){
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _traeInspectorLogeado();
    _refrescarMedicionesList();
  }

  Future<bool> _onBackPressed() {
    print('****_onBackPressed');
}
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Center(
            child: Text(widget.title,
              style: TextStyle(color: Colors.green[400]),),
          ),
          actions: <Widget>[
            PopupMenuButton(
                onSelected: OpcionSeleccionada,
                itemBuilder: (BuildContext context){
                  return Configuracion.choices.map((String choice) {
                    return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice));
                  }).toList();
                })
          ],
        ),
        body: Center(

          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Inspector: $inspector_nombre", textScaleFactor: 1.3),
                _list(),
                Visibility(
                  visible: _mostrarForm,
                  child: _form(),
                ),
              ],
            ),
        ),
      ),
    );
  }

  void OpcionSeleccionada(String choice) {
    procesando(context, 'averga');
    if (choice == Configuracion.Sincronizar) {
      _sincronizar();
    } else if (choice == Configuracion.LogOut) {
      _cerrarSesion();
    }
  }


  _list() => Expanded(
    child: Card(
      margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: ListView.builder(
        padding: EdgeInsets.all(7),
        itemBuilder: (context,index){
          return Column(
            children: <Widget>[
              ListTile(
                title: Text('('+_mediciones[index].padron+') '+_mediciones[index].direccion),
                subtitle: Text(
                    'Medidor: '+_mediciones[index].medidor +
                    ' Lectura Anterior: '+_mediciones[index].ultima_lectura.toString() +
                    ' Actual: ' + (_mediciones[index].lectura.toString() == 'null'?  '0' : _mediciones[index].lectura.toString()),
                ),
                leading: Icon(Icons.home,
                  color: _mediciones[index].lectura.toString() == 'null'?  Colors.grey[600] : Colors.greenAccent,
                ),
                onTap: () {
                  setState(() {
                    _medicion = _mediciones[index];
                    _ctrlMedidor.text = _mediciones[index].medidor;
                    if (_mediciones[index].lectura.toString() == 'null')
                      _ctrlLectura.text = '' ;
                    else
                      _ctrlLectura.text = _mediciones[index].lectura.toString() ;
                      _ctrlDomicilio.text = _mediciones[index].direccion;
                      _mostrarForm = !_mostrarForm;
                  });
                },
              ),
              // Text('Medidor: '+_mediciones[index].medidor,textScaleFactor: 0.9),
              // Text('Lectura: '+_mediciones[index].lectura.toString(),textScaleFactor: 0.9),
              Divider(
                height: 5.0,
              )
            ],
          );
        },
        itemCount: _mediciones.length,
      ),
    ),
  );

  _form() => Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical:15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              readOnly: true,
              controller: _ctrlDomicilio,
              decoration: InputDecoration(labelText: 'Domicilio'),
            ),
            TextFormField(
              readOnly: true,
              controller: _ctrlMedidor,
              decoration: InputDecoration(labelText: 'N° Medidor'),
            ),
            TextFormField(
              controller: _ctrlLectura,
              decoration: InputDecoration(labelText: 'Lectura'),
              keyboardType: TextInputType.number,
              autofocus: true,
              onSaved: (val) {
                setState(() {
                  _medicion.lectura = int.parse(val);
                  _medicion.fecha_lectura = DateTime.now().toString();
                });
              },
              validator: (val) {
                if (int.parse(val) < 0)
                  return 'La lectura debe ser mayor o igual a cero.';
                else
                if (_medicion.ultima_lectura > int.parse(val))
                  return 'Debe ser mayor a la última lectura' + ' (' +
                      _medicion.ultima_lectura.toString() + ')';
                else
                  return null;
              },
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              child: RaisedButton(
                onPressed: ()=> _onSumbit(),
                child: Text('Grabar Lectura'),
              ),
            )
          ],
        ),
      )
  );

  Future<http.Response> _sincronizar() async{
    List<Medicion> medicionesList = await _dbHelper.lecturasCargadas();
    if (medicionesList.length>0) {
      var url = urlSincronizar();
      var body = json.encode(medicionesList);
      var response;
      var ok = true;
      print('*** body: ' + body);
      try {
        response = await http.post(url, headers: {'Content-Type': "application/json"}, body:   body).timeout(const Duration(seconds: 5));
      } on TimeoutException catch (e) {
        mensajeError(context, 'Error', 'Tiempo de espera agotado. Revise su conexión y vuelva a intentarlo');
        ok = false;

      } on Error catch (e) {
        mensajeError(context, 'Error', 'Ocurrió un error, intente más tarde');
        ok = false;
      }
      if (ok == true) {
        print("***Response status: ${response.statusCode}");
        // print("Response body: ${response.contentLength}");
        // print("response.headers: " + response.headers);
        // print("response.request: " + response.request);
        if ( response.statusCode == 201 ) {
          _LimpiaBase();
          _descargaMediciones();
          mensajeExito(context, 'Éxito',
              'La base de datos se ha actualizado con éxito.');
        } else {
          var _error = 'Error (' + response.statusCode.toString() + ')';
          mensajeError(context, _error, 'Ocurrió un error, intente más tarde');
        }
        return response;
      }
    } else {
      // No hay mediciones para subir, únicamente descargo las mediciones
      _LimpiaBase();
      _descargaMediciones();
    }
  }

  Future _descargaMediciones() async {
    var url = urlDescarga()+inspector_id.toString();
    print('***url: ' + url);
    var response;
    var ok = true;

    try {
      response = await http.get(url).timeout(const Duration(seconds: 5));
    } on TimeoutException catch (e) {
      mensajeError(context, 'Error', 'Tiempo de espera agotado. Revise su conexión y vuelva a intentarlo');
      ok = false;
    } on Error catch (e) {
      mensajeError(context, 'Error', 'Ocurrió un error, intente más tarde');
      ok = false;
    }
    if (ok == true) {
      print('***response.statusCode: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        List mediciones = json.decode(response.body);
        List<Medicion> listaMediciones = mediciones.map((map) => Medicion.fromJson(map)).toList();
        for (var medicion in listaMediciones) {
          Medicion _medicionObject = Medicion(
              id: medicion.id,
              periodo: medicion.periodo,
              padron: medicion.padron,
              medidor: medicion.medidor,
              lectura: null,
              fecha_lectura: null,
              direccion: medicion.direccion,
              ultima_lectura: medicion.ultima_lectura,
              inspector: medicion.inspector
          );
          // Grabo en la base de datos
          _insertaDescargado(_medicionObject);
        }
        // Muestro en la List View
        List<Medicion> x = await _dbHelper.mostrarMediciones();
        setState(() {
          _mediciones = x;
        });
      }
    }
  }

  _onSumbit() async{
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (_medicion.id==null) await _dbHelper.insertMedicion(_medicion);
      else await _dbHelper.updateMedicion(_medicion);
      _refrescarMedicionesList();
      _resetForm();
    }
  }

  _insertaDescargado(Medicion medicion) async{
    await _dbHelper.insertJson(medicion);
  }

  _refrescarMedicionesList() async{
    List<Medicion> x = await _dbHelper.mostrarMediciones();
    setState(() {
      _mediciones = x;
    });
  }

  _traeInspectorLogeado() async{
    List<Inspector> x = await _dbHelper.buscaInspectores();
    inspector_nombre = x[0].nombre;
    inspector_id = x[0].id;
  }

  _LimpiaBase() async {
    await _dbHelper.deleteBase();
  }

  _resetForm() {
    setState(() {
      _formKey.currentState.reset();
      _ctrlDomicilio.clear();
      _ctrlLectura.clear();
      _ctrlMedidor.clear();
      _medicion.id = null;
      _mostrarForm = false;
    });
  }

  _cerrarSesion()async {
    await _dbHelper.logOut();
    print("Inspector deslogueado");
    Navigator.push(
        context,
        //MaterialPageRoute(builder: (context) => SecondRoute()),
        MaterialPageRoute(builder: (context) => LoginRoute()));
  }

}