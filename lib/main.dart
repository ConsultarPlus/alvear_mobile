import 'dart:convert';
import 'package:alvear/Config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:alvear/models/medicion.dart';
import 'package:alvear/utils/database_helper.dart';

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
      home: MyHomePage(title: 'Comuna Alvear - Lecturas'),
    );
  }
}

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
            _list(), _form()
          ],
        ),
      ),
    );
  }

  void OpcionSeleccionada(String choice) {
    if (choice == Configuracion.Sincronizar) {
      _sincronizar();
    } else if (choice == Configuracion.Descargar) {
      _LimpiaBase();
      _buscaMediciones();
    } else if (choice == Configuracion.Actualizar) {
      _refrescarMedicionesList();
    }
  }

  _form() => Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical:15, horizontal: 30),
      // height: altura,
      child: Form(
        key: _formKey,
        child: Column(
            children: <Widget>[
              TextFormField(
                readOnly: true,
                controller: _ctrlDomicilio,
                decoration: InputDecoration(labelText: 'Domicilio'),
                onSaved: (val) => setState(()=>_medicion.domicilio = val),
                // validator: (val)=>(val.length == 0 ? 'Debe cargar el domicilio':null),
              ),
              TextFormField(
                readOnly: true,
                controller: _ctrlMedidor,
                decoration: InputDecoration(labelText: 'N° Medidor'),
                onSaved: (val) => setState(()=>_medicion.medidor = val),
                // validator: (val)=>(val.length == 0 ? 'Debe cargar el medidor':null),
              ),
              TextFormField(
                controller: _ctrlLectura,
                decoration: InputDecoration(labelText: 'Lectura'),
                autofocus: true,
                onSaved: (val) => setState(()=>_medicion.lectura = int.parse(val)),
                validator: (val)=>(val.length>6 ?'Cuuidado, muy alto!':null),
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
      });
  }

  Future _buscaMediciones() async {
    var url = 'http://192.168.1.32:88/expediente/devuelve_json/';
    // var url = 'http://190.193.200.120:88/expediente/devuelve_json/';
    var jsonData = await http.get(url);
    if (jsonData.statusCode == 200) {
      // Map<String, dynamic> map = json.decode(jsonData.body);
      // List<dynamic> listaMediciones = map["json"];
      List mediciones = json.decode(jsonData.body);
      List<Medicion> listaMediciones = mediciones.map((map) => Medicion.fromJson(map)).toList();
      for (var medicion in listaMediciones) {
        // mediciones.add(Medicion.fromMap(medicion));
        Medicion _medicionObject = Medicion(
            id: medicion.id,
            periodo: medicion.periodo,
            padron: medicion.padron,
            medidor: medicion.medidor,
            lectura: 0,
            domicilio: medicion.domicilio,
            ultima: medicion.ultima,
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
    List<Medicion> medicionesList = await _dbHelper.mostrarMediciones();
    // String medicionesJson = json.encode(medicionesList);
    var url = 'http://127.0.0.1:8000/inspecciones/json_inspector/';
    // var url = 'http://192.168.1.32:88/expediente/sincroniza_json/';
    // var url = 'http://190.193.200.120:88/expediente/sincroniza_json/';
    var body = json.encode(medicionesList);
    print('body: '+ body);

    var response = await http.post(url, headers: {'Content-Type': "application/json"}, body: body);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
      print(response.headers);
      print(response.request);
    return response;
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
                leading: Icon(Icons.home),
                onTap: () {
                  setState(() {
                    _medicion = _mediciones[index];
                    _ctrlMedidor.text = _mediciones[index].medidor;
                    _ctrlLectura.text = _mediciones[index].lectura.toString();
                    _ctrlDomicilio.text = _mediciones[index].domicilio;
                  });
                },
              ),
              Text('Medidor: '+_mediciones[index].medidor,textScaleFactor: 0.9),
              Text('Lectura: '+_mediciones[index].lectura.toString(),textScaleFactor: 0.9),
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

class CargaLectura extends StatelessWidget {

  final String itemHolder ;

  CargaLectura({Key key, @required this.itemHolder}) : super(key: key);

  goBack(BuildContext context){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Second Activity Screen"),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child:
              Text('Selected Item = ' + itemHolder,
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.center,)),

              RaisedButton(
                onPressed: () {goBack(context);},
                color: Colors.lightBlue,
                textColor: Colors.white,
                child: Text('Go Back To Previous Screen'),
              )])
    );
  }
}