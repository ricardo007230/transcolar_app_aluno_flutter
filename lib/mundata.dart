import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const tableMunData = 'mun_data';
const columnCodMun = 'cod_mun';
const columnSiglaEst = 'sigla_est';
const columnViagemId = 'viagem_id';

class MunDataDatabase {
  static final MunDataDatabase instance = MunDataDatabase._init();

  static Database? _database;

  MunDataDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('mundata.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableMunData (
        $columnCodMun INTEGER PRIMARY KEY,
        $columnSiglaEst TEXT,
        $columnViagemId INTEGER
      )
      ''');
  }

  Future<void> insertMunData(int codMun, String siglaEst, int viagemId) async {
    final db = await instance.database;
    await db.insert(
        tableMunData,
        {
          columnCodMun: codMun,
          columnSiglaEst: siglaEst,
          columnViagemId: viagemId
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> fetchMunData() async {
    final db = await instance.database;
    final maps = await db.query(tableMunData, limit: 1);
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> deleteMunData() async {
    final db = await instance.database;
    await db.delete(tableMunData);
  }
}
