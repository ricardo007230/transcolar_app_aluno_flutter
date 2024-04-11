//import 'package:postgres/postgres.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;

  DatabaseHelper._privateConstructor();

  static Future<Database> getDatabase() async {
    final databasePath = await getDatabasesPath();
    final dbPath = join(databasePath, 'estados.db');

    final db = await openDatabase(dbPath);

    return db;
  }

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._privateConstructor();
    return _instance!;
  }

  
  static Future<List<String>> fetchEstados() async {
    final db = await getDatabase();

    final res = await db.rawQuery('SELECT DISTINCT UF FROM estados');
    var list = <String>[];

    for (final o in res) {
      list.add(o['UF'].toString());
    }

    return list;
  }

  static Future<List<String>> fetchMunicipios(String estado) async {
    final db = await getDatabase();

    final res = await db.rawQuery(
        "SELECT DISTINCT nomeEstado FROM estados WHERE UF = '$estado' ORDER BY nomeEstado ASC");
    var list = <String>[];

    for (final o in res) {
      list.add(o['nomeEstado'].toString());
    }

    return list;
  }

  Future<int?> fetchCodMun(String nomeMun, String siglaEst) async {
    final db = await getDatabase();
    final res = await db.rawQuery(
        "SELECT codigo7 FROM estados WHERE nomeEstado = '$nomeMun' AND UF = '$siglaEst'");

    if (res.isNotEmpty) {
      return int.parse(res[0]['codigo7'].toString());
    }

    return null;
  }

  static Future<void> sendViagemToRemote(Map<String, dynamic> viagem) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String ?model = prefs.getString('model');
      final String ?manufacturer = prefs.getString('manufacturer');
      final String ?platform = prefs.getString('platform');
      final String ?version = prefs.getString('version');
      final bool ?magentometer = prefs.getBool('magentometer');
      final bool ?accelerometer = prefs.getBool('accelerometer');
      final bool ?gyroscope = prefs.getBool('gyroscope');
      final String cpfMotorista = viagem['cpf_motorista'];
      final String placa = viagem['placa'];
      final String motorista = viagem['motorista'];
      //final String date = viagem[''];
      final String codigoViagem = viagem['codigo_viagem'];
      final String siglaEst = viagem['sigla_est'];
      final int codMun = int.parse(viagem['cod_mun']);
      final String horario = viagem['horario'];
      //final String horarioMarkers = viagem['horario_markers'];
      final String altitude = viagem['altitude'];
      final String odometro = viagem['odometro'];
      final String velocidade = viagem['velocidade'];
      final String sentido = viagem['sentido'];
      final String precisao = viagem['precisao'];

      print("Modelo: $model \nManufacturer:q $manufacturer \nplataform: $platform \nversion: $version");
      print("magentometer: $magentometer \naccelerometer: $accelerometer \ngyroscope: $gyroscope");


      Map<String, dynamic> requestBody = {
        "sigla_est": siglaEst,
        "cod_mun": codMun,
        "nome_viagem": codigoViagem,
        "nome_motorista": motorista,
        "cpf_motorista": cpfMotorista,
        "placa": placa,
        "horario_pontos": horario.split(','),
        "altitude":
            altitude.split(',').map((alt) => double.parse(alt)).toList(),
        "odometro": odometro.split(',').map((od) => double.parse(od)).toList(),
        "velocidade":
            velocidade.split(',').map((o) => double.parse(o)).toList(),
        "sentido": sentido.split(',').map((o) => double.parse(o)).toList(),
        "precisao": precisao.split(',').map((o) => double.parse(o)).toList(),
        "modelo": model,
        "manufacturer": manufacturer,
        "platform": platform,
        "version": version,
        "magentometer": magentometer,
        "accelerometer": accelerometer,
        "gyroscope": gyroscope,
      };

      String requestBodyJson = json.encode(requestBody);

      print(requestBodyJson);

      String valorSalvo = prefs.getString('userKey') ?? '';

      String url =
          "http://geoter.transcolares.etg.ufmg.br:8881/approteiros/enviarRoteiro?authToken=$valorSalvo";
    
      // Enviar a requisição POST
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: requestBodyJson,
      );

      if (response.statusCode != 200) {
        throw '${response.statusCode}';
      }
    } catch (error) {
      throw '$error';
    }
  }

  static List<bool> paradasLista(List<double> xlat, List<double> xlng,
      List<double> ylat, List<double> ylng) {
    if (xlat.length != xlng.length || ylat.length != ylng.length) {
      throw "Listas incompativeis";
    }

    if (ylat.isEmpty) {
      return List<bool>.filled(xlat.length, false);
    } else {
      List<bool> paradas = [];
      bool added = false;

      for (int i = 0; i < xlat.length; i++) {
        for (int j = 0; j < ylat.length; j++) {
          if (xlat[i] == ylat[j] && xlng[i] == ylng[j]) {
            paradas.add(true);
            added = true;
            break;
          }
        }
        if (added) {
          added = false;
        } else {
          paradas.add(false);
        }
      }

      return paradas;
    }
  }

}
