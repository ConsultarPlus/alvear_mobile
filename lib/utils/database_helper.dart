import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:alvear/models/medicion.dart';
import 'package:alvear/models/inspector.dart';

class DatabaseHelper{
  static const _databaseName= 'Mediciones.db';
  static const _databaseVersion= 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database _database;
  Future<Database> get database async{
    if(_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async{
    Directory dataDirectory =await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    return await openDatabase(dbPath,version: _databaseVersion, onCreate: _onCreateDB);
  }

  _onCreateDB(Database db,   version) async{
    await db.execute('''
      CREATE TABLE ${Medicion.tblMedicion}(
        ${Medicion.colId} INTEGER PRIMARY KEY AUTOINCREMENT,        
        ${Medicion.colPeriodo} TEXT NULL,
        ${Medicion.colPadron} TEXT NULL,
        ${Medicion.colMedidor} TEXT NULL,
        ${Medicion.colLectura} INTEGER NULL,
        ${Medicion.colFecha} TEXT NULL,
        ${Medicion.colDireccion} TEXT NULL,
        ${Medicion.colUltima} INTEGER NULL,
        ${Medicion.colInspector} INTEGER NULL,
        ${Medicion.colObservacion} TEXT NULL
        )  
    ''');
    await db.execute('''
      CREATE TABLE ${Inspector.tblInspector}(
        ${Inspector.colId} INTEGER PRIMARY KEY AUTOINCREMENT,        
        ${Inspector.colDni} INTEGER NULL,
        ${Inspector.colNombre} TEXT NULL,
        ${Inspector.colEmail} TEXT NULL,
        ${Inspector.colClave} TEXT NULL,
        ${Inspector.colLogueado} TEXT NULL        
        )  
    ''');
  }

  // """ CONSULTAS MEDICIONES/LECTURAS """

  Future<void> insertJson(Medicion medicion) async{
    Database db = await database;
    await db.insert(Medicion.tblMedicion, medicion.toJson(), conflictAlgorithm:
    ConflictAlgorithm.replace);
  }

  Future<int> insertMedicion(Medicion medicion) async {
    Database db = await database;
    return await db.insert(Medicion.tblMedicion, medicion.toMap());
  }

  Future<int> updateMedicion(Medicion medicion) async {
    Database db = await database;
    return await db.update(Medicion.tblMedicion, medicion.toMap(),
    where: '${Medicion.colId}=?',whereArgs: [medicion.id]);
  }

  Future<int> deleteBase() async {
    Database db = await database;
    await db.execute('''
    DELETE FROM  ${Medicion.tblMedicion}
    ''');
  }

  Future<List<Medicion>> mostrarMediciones(inspectorId) async{
    Database db = await database;
    // raw query
    List<Map> mediciones = await db.rawQuery('SELECT * FROM  ${Medicion.tblMedicion} WHERE ${Medicion.colInspector}=?', [inspectorId]);
    // mediciones.forEach((row) => print(row));
    return mediciones.length == 0
    ?[]
    :mediciones.map((e) => Medicion.fromMap(e)).toList();
  }

  Future<List<Medicion>> lecturasCargadas() async{
    Database db = await database;
    int lect1 = 0;
    String lect2 = '';
    List<Map> mediciones =await db.query(Medicion.tblMedicion,where: '${Medicion.colLectura}>=? or ${Medicion.colObservacion}!=?', whereArgs: [lect1, lect2]);
    return mediciones.length == 0
        ?[]
        :mediciones.map((e) => Medicion.fromMap(e)).toList();
  }

  // """ CONSULTAS INSPECTORES """

  Future<void> insertInspector(Inspector inspector) async{
    Database db = await database;
    await db.insert(Inspector.tblInspector, inspector.toJson(), conflictAlgorithm:
    ConflictAlgorithm.replace);
  }

  Future<List<Inspector>> buscaInspectores() async{
    Database db = await database;
    // String logged = "S";
    List<Map> inspectores =await db.query(Inspector.tblInspector);
    return inspectores.length == 0
        ?[]
        :inspectores.map((e) => Inspector.fromMap(e)).toList();
  }

  // El logIn es una bandera que marca cual es el inspector logueado
  Future<int> logIn(Inspector inspector) async {
    Database db = await database;
    return await db.update(Inspector.tblInspector, inspector.toMap(),
        where: '${Inspector.colId}=?',whereArgs: [inspector.id]);
  }

  Future<int> logOut() async {
    Database db = await database;
    await db.execute('''
    UPDATE ${Inspector.tblInspector}
      SET ${Inspector.colLogueado} = "N"        
    ''');
    // await db.execute('''
    // DELETE FROM  ${Inspector.tblInspector}
    // ''');
  }
}