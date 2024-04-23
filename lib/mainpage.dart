import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  const MainPage({Key? key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        backgroundColor: Colors.orange, // Updated color for a more calming feel
      ),
      body: SingleChildScrollView( // Ensures content doesn't overflow
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20.0), // Increased spacing for better readability
            _buildRegistrationStep(
              stepNumber: 1,
              stepText: 'Registrar casa',
              onPressed: () => Navigator.pushReplacementNamed(context, "/casa"),
              backgroundColor: Colors.orange, // Consistent color scheme
            ),
            const SizedBox(height: 20.0),
            _buildRegistrationStep(
              stepNumber: 2,
              stepText: 'Registrar escola',
              onPressed: () => Navigator.pushReplacementNamed(context, "/escola"),
              backgroundColor: Colors.orange[200] ?? Colors.tealAccent, // Lighter shade
            ),
            const SizedBox(height: 20.0),
            _buildRegistrationStep(
              stepNumber: 3,
              stepText: 'Enviar dados',
              onPressed: () => sendDadosToRemote(), // Assuming functionality not yet implemented
              backgroundColor: Colors.orange[300] ?? Colors.tealAccent, // Even lighter shade
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationStep({
    required int stepNumber,
    required String stepText,
    required void Function() onPressed,
    Color backgroundColor = Colors.tealAccent,
    bool isEnabled = true,
  }) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(20.0),
      ),
      child: Row(
        children: <Widget>[
          Text(
            'Passo $stepNumber: $stepText',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (isEnabled)
            const Icon(Icons.arrow_forward_ios, color: Colors.black),
        ],
      ),
    );
  }

  static Future<void> sendDadosToRemote() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final double? lat_casa = prefs.getDouble("lat_casa");
      final double? lng_casa = prefs.getDouble("lng_casa");
      final double? lat_escola = prefs.getDouble("lat_escola");
      final double? lng_escola = prefs.getDouble("lng_escola");
      final int? codMun = prefs.getInt("codMun");
      final String? Name = prefs.getString("Name");
      final String? email = prefs.getString("email");
      final String? sigla_est = prefs.getString("siglaEst");
      final String? nome_escola = prefs.getString("nome_escola");

      Map<String, dynamic> requestBody = {
        "email": email,
        "sigla_est": sigla_est,
        "nome_escola": nome_escola,
        "cod_mun": codMun,
        "nome_aluno": Name,
        "lat_casa": lat_casa,
        "lng_casa": lng_casa,
        "lat_escola": lat_escola,
        "lng_escola": lng_escola,
      };

      String requestBodyJson = json.encode(requestBody);

      print(requestBodyJson);

      String valorSalvo = prefs.getString('userKey') ?? '';

      String url =
          "http://geoter.transcolares.etg.ufmg.br:8881/approteiros/enviarRoteiro?authToken=$valorSalvo"; //MUDAR LINK
    
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
}