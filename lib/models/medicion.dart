class Medicion {
  static const tblMedicion = 'mediciones';
  static const colId = 'id';
  static const colPeriodo = 'periodo';
  static const colPadron = 'padron';
  static const colMedidor = 'medidor';
  static const colLectura = 'lectura';
  static const colFecha = 'Fecha';
  static const colDomicilio = 'domicilio';
  static const colUltima = 'ultima';
  static const colInspector = 'inspector';

  Medicion({this.id, this.periodo, this.padron, this.medidor, this.lectura, this.fecha, this.domicilio, this.ultima, this.inspector});

  Medicion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    periodo = json['periodo'];
    padron = json['padron'];
    medidor = json['medidor'];
    lectura = json['lectura'];
    fecha = json['fecha'];
    domicilio = json['domicilio'];
    ultima = json['ultima_lectura'];
    inspector = json['inspector'];
  }

  Medicion.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    periodo = map[colPeriodo];
    padron = map[colPadron];
    medidor = map[colMedidor];
    lectura = map[colLectura];
    fecha = map[colFecha];
    domicilio = map[colDomicilio];
    ultima = map[colUltima];
    inspector = map[colInspector];
  }

  int id;
  String periodo;
  String padron;
  String medidor;
  int lectura;
  String fecha;
  String domicilio;
  int ultima;
  int inspector;

  Map<String, dynamic> toJson() {
    final json =<String, dynamic>{};
    json['id'] = this.id;
    json['periodo'] = this.periodo;
    json['padron'] = this.padron;
    json['medidor'] = this.medidor;
    json['lectura'] = this.lectura;
    json['fecha'] = this.fecha;
    json['domicilio'] = this.domicilio;
    json['ultima'] = this.ultima;
    json['inspector'] = this.inspector;
    return json;
  }


  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colMedidor: medidor, colLectura: lectura, colDomicilio: domicilio};
    if (id != null) map[colId] = id;
    return map;
  }
}

class User {
  final String name;
  final String email;

  User(this.name, this.email);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'email': email,
      };
}
