import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:alvear/models/medicion.dart';
import 'package:alvear/utils/database_helper.dart';
import 'package:alvear/Config.dart';
import 'package:http/http.dart' as http;
import 'login_route.dart';


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
  @override
  void initState(){
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _refrescarMedicionesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _list(),
            Visibility(
              visible: _mostrarForm,
              child: _form(),
            ),
          ],
        ),
      ),
    );
  }

  void OpcionSeleccionada(String choice) {
    if (choice == Configuracion.Sincronizar) {
      _sincronizar();
    } else if (choice == Configuracion.Descargar) {
      _sincronizar();
      _LimpiaBase();
      _buscaMediciones();
    } else if (choice == Configuracion.Actualizar) {
      _refrescarMedicionesList();
    } else if (choice == Configuracion.LogOut) {
      _cerrarSesion();
    }
  }

  _cerrarSesion()async {
    await _dbHelper.logOut();
    print("Inspector deslogueado");
    Navigator.push(
        context,
        //MaterialPageRoute(builder: (context) => SecondRoute()),
        MaterialPageRoute(builder: (context) => LoginRoute()));
  }

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

  _refrescarMedicionesList() async{
    List<Medicion> x = await _dbHelper.mostrarMediciones();
    setState(() {
      _mediciones = x;
    });
  }

  _insertaDescargado(Medicion medicion) async{
    await _dbHelper.insertJson(medicion);
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

  Future _buscaMediciones() async {
    var url = 'http://10.0.2.2:8000/inspecciones/descarga_json/';
    // var url = 'http://190.193.200.120:88/expediente/devuelve_json/';
    var jsonData = await http.get(url);
    if (jsonData.statusCode == 200) {
      List mediciones = json.decode(jsonData.body);
      List<Medicion> listaMediciones = mediciones.map((map) => Medicion.fromJson(map)).toList();
      for (var medicion in listaMediciones) {
        Medicion _medicionObject = Medicion(
            id: medicion.id,
            periodo: medicion.periodo,
            padron: medicion.padron,
            medidor: medicion.medidor,
            lectura: null,
            fecha_lectura: null,
            domicilio: medicion.domicilio,
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

  Future<http.Response> _sincronizar() async{
    List<Medicion> medicionesList = await _dbHelper.lecturasCargadas();
    var url = 'http://10.0.2.2:8000/inspecciones/sincronizar_json/';
    var body = json.encode(medicionesList);
    print('body: '+ body);

    var response = await http.post(url, headers: {'Content-Type': "application/json"}, body:   body);
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.contentLength}");
    print(response.headers);
    print(response.request);
    return response;
  }

  Future _buscaInspectores() async {
    var url = 'http://10.0.2.2:8000/inspecciones/inspectores_json/';
    // var url = 'http://190.193.200.120:88/expediente/devuelve_json/';
    var jsonData = await http.get(url);
    if (jsonData.statusCode == 200) {
      List mediciones = json.decode(jsonData.body);
      List<Medicion> listaMediciones = mediciones.map((map) => Medicion.fromJson(map)).toList();
      for (var medicion in listaMediciones) {
        Medicion _medicionObject = Medicion(
            id: medicion.id,
            periodo: medicion.periodo,
            padron: medicion.padron,
            medidor: medicion.medidor,
            lectura: null,
            fecha_lectura: null,
            domicilio: medicion.domicilio,
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

  _list() => Expanded(
    child: Card(
      margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: ListView.builder(
        padding: EdgeInsets.all(7),
        itemBuilder: (context,index){
          return Column(
            children: <Widget>[
              ListTile(
                title: Text('('+_mediciones[index].padron+') '+_mediciones[index].domicilio),
                subtitle: Text(
                    'Medidor: '+_mediciones[index].medidor + ' Lectura: '+_mediciones[index].lectura.toString()+ ' Anterior: '+_mediciones[index].ultima_lectura.toString()
                ),
                leading: Icon(Icons.home,
                  color: _mediciones[index].lectura.toString() == '0'?  Colors.grey[600] : Colors.greenAccent,
                ),
                onTap: () {
                  setState(() {
                    _medicion = _mediciones[index];
                    _ctrlMedidor.text = _mediciones[index].medidor;
                    if (_mediciones[index].lectura.toString() == 'null')
                      _ctrlLectura.text = '' ;
                    else
                      _ctrlLectura.text = _mediciones[index].lectura.toString() ;
                      _ctrlDomicilio.text = _mediciones[index].domicilio;
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
}