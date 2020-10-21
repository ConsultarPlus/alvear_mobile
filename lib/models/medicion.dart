class Medicion {
  static const tblMedicion = 'mediciones';
  static const colId = 'id';
  static const colPeriodo = 'periodo';
  static const colPadron = 'padron';
  static const colMedidor = 'medidor';
  static const colLectura = 'lectura';
  static const colFecha = 'fecha_lectura';
  static const colDomicilio = 'domicilio';
  static const colUltima = 'ultima_lectura';
  static const colInspector = 'inspector';

  Medicion({this.id, this.periodo, this.padron, this.medidor, this.lectura, this.fecha_lectura, this.domicilio, this.ultima_lectura, this.inspector});

  Medicion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    periodo = json['periodo'];
    padron = json['padron'];
    medidor = json['medidor'];
    lectura = json['lectura'];
    fecha_lectura = json['fecha_lectura'];
    domicilio = json['domicilio'];
    ultima_lectura = json['ultima_lectura'];
    inspector = json['inspector'];
  }

  Medicion.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    periodo = map[colPeriodo];
    padron = map[colPadron];
    medidor = map[colMedidor];
    lectura = map[colLectura];
    fecha_lectura = map[colFecha];
    domicilio = map[colDomicilio];
    ultima_lectura = map[colUltima];
    inspector = map[colInspector];
  }

  int id;
  String periodo;
  String padron;
  String medidor;
  int lectura;
  String fecha_lectura;
  String domicilio;
  int ultima_lectura;
  int inspector;

  Map<String, dynamic> toJson() {
    final json =<String, dynamic>{};
    json['id'] = this.id;
    json['periodo'] = this.periodo;
    json['padron'] = this.padron;
    json['medidor'] = this.medidor;
    json['lectura'] = this.lectura;
    json['fecha_lectura'] = this.fecha_lectura;
    json['domicilio'] = this.domicilio;
    json['ultima_lectura'] = this.ultima_lectura;
    json['inspector'] = this.inspector;
    return json;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colLectura: lectura, colFecha: fecha_lectura};
    if (id != null) map[colId] = id;
    return map;
  }
}

class Inspector {
  static const tblInspector = 'inspector';
  static const colId = 'id';
  static const colDni = 'dni';
  static const colNombre = 'nombre';
  static const colEmail = 'e_mail';
  static const colClave = 'clave_app';

  int id;
  int dni;
  String nombre;
  String e_mail;
  String clave_app;

  Inspector({this.id, this.dni, this.nombre, this.e_mail, this.clave_app});

  Inspector.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dni = json['dni'];
    nombre = json['nombre'];
    e_mail = json['e_mail'];
    clave_app = json['clave_app'];
  }

  Map<String, dynamic> toJson() {
    final json =<String, dynamic>{};
    json['id'] = this.id;
    json['dni'] = this.dni;
    json['nombre'] = this.nombre;
    json['e_mail'] = this.e_mail;
    json['clave_app'] = this.clave_app;
    return json;
  }

  Inspector.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    dni = map[colDni];
    nombre = map[colNombre];
    e_mail = map[colEmail];
    clave_app = map[colClave];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colId: id};
    if (id != null) map[colId] = id;
    return map;
  }
}
