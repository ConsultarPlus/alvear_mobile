import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:alvear/models/medicion.dart';

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
        ${Medicion.colDomicilio} TEXT NULL,
        ${Medicion.colUltima} INTEGER NULL,
        ${Medicion.colInspector} INTEGER NULL
        )  
    ''');
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

  Future<List<Medicion>> mostrarMediciones() async{
    Database db = await database ;
    List<Map> mediciones =await db.query(Medicion.tblMedicion);
    return mediciones.length == 0
    ?[]
    :mediciones.map((e) => Medicion.fromMap(e)).toList();
  }
}