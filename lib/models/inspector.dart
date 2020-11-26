class Inspector {
  static const tblInspector = 'inspector';
  static const colId = 'id';
  static const colDni = 'dni';
  static const colNombre = 'nombre';
  static const colEmail = 'e_mail';
  static const colClave = 'clave_app';
  static const colLogueado = 'logueado';

  int id;
  int dni;
  String nombre;
  String e_mail;
  String clave_app;
  String logueado;

  Inspector({this.id, this.dni, this.nombre, this.e_mail, this.clave_app, this.logueado});

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
    json['logueado'] = this.logueado;
    return json;
  }

  Inspector.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    dni = map[colDni];
    nombre = map[colNombre];
    e_mail = map[colEmail];
    clave_app = map[colClave];
    logueado = map[colLogueado];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colId: id, colLogueado: logueado};
    if (id != null) map[colId] = id;
    return map;
  }
}
