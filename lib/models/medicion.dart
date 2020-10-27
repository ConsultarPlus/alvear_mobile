class Medicion {
  static const tblMedicion = 'mediciones';
  static const colId = 'id';
  static const colPeriodo = 'periodo';
  static const colPadron = 'padron';
  static const colMedidor = 'medidor';
  static const colLectura = 'lectura';
  static const colFecha = 'fecha_lectura';
  static const colDireccion = 'direccion';
  static const colUltima = 'ultima_lectura';
  static const colInspector = 'inspector';

  Medicion({this.id, this.periodo, this.padron, this.medidor, this.lectura,
            this.fecha_lectura, this.direccion, this.ultima_lectura,
            this.inspector});

  Medicion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    periodo = json['periodo'];
    padron = json['padron'];
    medidor = json['medidor'];
    lectura = json['lectura'];
    fecha_lectura = json['fecha_lectura'];
    direccion = json['direccion'];
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
    direccion = map[colDireccion];
    ultima_lectura = map[colUltima];
    inspector = map[colInspector];
  }

  int id;
  String periodo;
  String padron;
  String medidor;
  int lectura;
  String fecha_lectura;
  String direccion;
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
    json['direccion'] = this.direccion;
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
