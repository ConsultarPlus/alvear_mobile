import 'dart:async';
import 'dart:io';
// import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_route.dart';
import 'package:alvear/models/inspector.dart';
import 'package:alvear/models/medicion.dart';
import 'package:alvear/utils/database_helper.dart';
import 'package:alvear/utils/mensajes.dart';
import 'package:alvear/utils/urls.dart';
import 'package:alvear/utils/globals.dart' as globals;
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
  List<Medicion> _medicionesAux =[]; // Son las lecturas filtradas
  DatabaseHelper _dbHelper ;
  final _formKey = GlobalKey<FormState>();
  final _ctrlMedidor = TextEditingController();
  final _ctrlLectura = TextEditingController();
  final _ctrlDomicilio = TextEditingController();
  bool _mostrarForm = false;
  String _periodo;

  @override
  void initState(){
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
      _periodo = " ";
    });
    _traePeriodo();
    _refrescarMedicionesList()  ;
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
          actions:
          <Widget>[
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
          // <Widget>[
          //   IconButton(icon: Icon(Icons.search), onPressed: () {})
          // ],
        ),
        body: Center(

          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Inspector: "+ globals.inspector_nombre, textScaleFactor: 1.3),
                Text("Período: "+ _periodo, textScaleFactor: 1.3),
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

  @override
  void OpcionSeleccionada(String choice) {
    if (choice == Configuracion.Sincronizar) {
      _sincronizar();
    } else if (choice == Configuracion.LogOut) {
      _cerrarSesion();
    }
  }

  ///////////// LISTA ////////////////////////flu
  _list() => Expanded(
    child: Card(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 5),
      child: ListView.builder(
        padding: EdgeInsets.all(5),
        itemBuilder: (context, index) {
          return index==0 ? _searchBar() : _listarItem(index-1);
        },
        itemCount: _medicionesAux.length+1,
      ),
    ),
  );

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Buscar por Medidor o Dirección..."
        ),
        onChanged: (text){
          text = text.toLowerCase();
          setState(() {
            _medicionesAux = _mediciones.where( (medicion){
              var medidor = medicion.medidor.toLowerCase() + medicion.direccion.toLowerCase();
              return medidor.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  _listarItem(index) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('('+_medicionesAux[index].medidor+') '+_medicionesAux[index].direccion, style: TextStyle(color: Colors.black),),
          subtitle: Text(
            'Padrón: '+_medicionesAux[index].padron +
                ' - Lectura Anterior: '+_medicionesAux[index].ultima_lectura.toString() +
                ' - Actual: ' + (_medicionesAux[index].lectura.toString() == 'null'?  '0' : _medicionesAux[index].lectura.toString()),
            textScaleFactor: 1,
            style: TextStyle(color: Colors.black),
          ),
          leading: Icon(Icons.home,
          color: _medicionesAux[index].lectura.toString() == 'null'?  Colors.grey[600] : Colors.greenAccent,size: 40,
        ),
          onTap: () {
            setState(() {
              _medicion = _medicionesAux[index];
              _ctrlMedidor.text = _medicionesAux[index].medidor;
              if (_medicionesAux[index].lectura.toString() == 'null')
                _ctrlLectura.text = '' ;
              else
                _ctrlLectura.text = _medicionesAux[index].lectura.toString() ;
              _ctrlDomicilio.text = _medicionesAux[index].direccion;
              _mostrarForm = !_mostrarForm;
            });
          },
        ),
        Divider(
          height: 5.0,
        )
      ],
    );
  }
  ///////////////////////////////////////////

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
      // Hay mediciones nuevas para subir, las subo
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
      } on SocketException catch (e) {
        mensajeError(context, 'Error', 'Tiempo de espera agotado. Revise su conexión y vuelva a intentarlo');
        ok = false;
      }
      print(ok);
      if (ok == true) {
        print("***Response status: ${response.statusCode}");
        // print("Response body: ${response.contentLength}");
        // print("response.headers: " + response.headers);
        // print("response.request: " + response.request);
        if ( response.statusCode == 201 ) {
          // _LimpiaBase();
          _descargaMediciones();
          // mensajeExito(context, 'Éxito',
          //     'La base de datos se ha actualizado con éxito.');
        } else {
          var _error = 'Error (' + response.statusCode.toString() + ')';
          mensajeError(context, _error, 'Ocurrió un error, intente más tarde');
        }
        return response;
      }
    } else {
      // No hay mediciones para subir, únicamente descargo las mediciones si es que hay nuevas
      // _LimpiaBase(); // cuidado con ésto que borra toda la DB!!
      _descargaMediciones();
      _traePeriodo();
      // mensajeExito(context, 'Éxito',
      // 'La base de datos se ha actualizado con éxito.');
    }
  }

  Future _descargaMediciones() async{
    var url = urlDescarga()+globals.inspector_ID.toString();
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
    } on SocketException catch (e) {
      mensajeError(context, 'Error', 'Tiempo de espera agotado. Revise su conexión y vuelva a intentarlo');
      ok = false;
    }
    if (ok == true) {
      print('***response.statusCode: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        _LimpiaBase();
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
        List<Medicion> x = await _dbHelper.mostrarMediciones(globals.inspector_ID);
        setState(() {
          _mediciones = x;
          _medicionesAux = _mediciones;
          _periodo = x[0].periodo;
        });
        _refrescarMedicionesList();
        mensajeExito(context, 'Éxito',
            'La base de datos se ha actualizado con éxito.');
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
    List<Medicion> x = await _dbHelper.mostrarMediciones(globals.inspector_ID);
    setState(() {
      _mediciones = x;
      _medicionesAux = _mediciones;
    });
  }

  _traePeriodo() async{
    List<Medicion> y = await _dbHelper.mostrarMediciones(globals.inspector_ID);
    if (y.length > 0) {
      globals.periodo = y[0].periodo;
    } else {
      globals.periodo = "-Sin Lecturas-";
    }
    setState(() {
      _periodo = globals.periodo;
    });
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