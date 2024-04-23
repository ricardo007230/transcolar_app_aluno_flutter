import 'dart:async';

import 'package:app_aluno/signup_page.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'mundata.dart';
import 'estados_database.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _chaveController = TextEditingController();

  String defaultEstado = '--';
  List<String>? estados;
  List<String>? municipios;
  String selectedEstado = '';
  String selectedMunicipio = '';
  String valueKey = 'insira sua chave aqui';
  String tmpMunicipio = '';

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
    fetchEstados();
  }

  Future<void> _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? tmpKey = prefs.getString('userKey');
    String? tmpCity = prefs.getString('City');
    if (tmpKey != null && tmpKey.isNotEmpty && tmpCity != null) {
      setState(() {
        valueKey = tmpKey;
        _chaveController.text = tmpKey;
        tmpMunicipio = tmpCity;
      });
    }
  }

  Future<void> fetchEstados() async {
    await initializeDatabase();
    final fetchedEstados = await DatabaseHelper.fetchEstados();

    setState(() {
      estados = [defaultEstado, ...fetchedEstados];
      if (fetchedEstados.isNotEmpty) {
        selectedEstado = defaultEstado;
      }
    });
  }

  Future<void> fetchMunicipios(String estado) async {
    final fetchedMunicipios = await DatabaseHelper.fetchMunicipios(estado);

    setState(() {
      municipios = fetchedMunicipios;
      if (fetchedMunicipios.isNotEmpty) {
        selectedMunicipio = fetchedMunicipios[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    backgroundColor: Colors.orange,
    title: const Text(
      'Transcolar Rural',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,
  ),
      backgroundColor: Colors.white, // Set background color to white
      body: Stack(
        children: [
          //Background image positioned behind the content
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/TelaFundo.jpg'),
                  scale: 4,
                  repeat: ImageRepeat.repeat,
                  opacity: 0.8, // Reduce background image opacity
                ),
              ),
            ),
          ),
          Positioned(
            top: 50.0,
            left: 20.0, // Adjust content padding
            right: 20.0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white, // Set card background to white
                borderRadius: BorderRadius.circular(10.0), // Add rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // Add subtle shadow
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Consulte o seu gestor Transcolar Rural para obter a chave para instalação',
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 25.0),
                  SizedBox(
                    width: 250, // Adjust text field width
                    height: 80,
                    child: TextField(
                      controller: _chaveController,
                      decoration: InputDecoration(
                        hintText: _chaveController.text.isEmpty
                            ? 'Insira sua chave aqui'
                            : '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Rounded corners for text field
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Estado:',
                    style: TextStyle(color: Colors.black),    ),
                  if (estados != null && estados!.isNotEmpty)
                    DropdownButton<String>(
                      value: selectedEstado,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedEstado = newValue!;
                          selectedMunicipio = '';
                          municipios = [];
                          fetchMunicipios(selectedEstado);
                        });
                      },
                      items: estados!
                          .map((estado) => DropdownMenuItem<String>(
                                value: estado,
                                child: Text(
                                  estado,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ))
                          .toList(),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(10.0), // Dropdown border radius
                    ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Município:',
                    style: TextStyle(color: Colors.black),
                  ),
                  if (municipios != null && municipios!.isNotEmpty)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: DropdownButton<String>(
                          value: selectedMunicipio,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMunicipio = newValue!;
                            });
                          },
                          items: municipios!.map<DropdownMenuItem<String>>(
                              (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      final completer = Completer<void>();

                      String chave = _chaveController.text;
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('userKey', chave);
                      prefs.setString('City', selectedMunicipio);
                      prefs.setString('siglaEst', selectedEstado);

                      final munData =
                          await MunDataDatabase.instance.fetchMunData();

                      if (munData != null) {
                        prefs.setInt('codMun', munData['cod_mun']);

                        completer.future.then((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        });
                      } else {
                        final codMun = await DatabaseHelper.instance
                            .fetchCodMun(selectedMunicipio, selectedEstado);
                        if (codMun != null) {
                          prefs.setInt('codMun', codMun);
                          print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
                          MunDataDatabase.instance
                              .insertMunData(codMun, selectedEstado, 0);

                          completer.future.then((_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupPage(),
                              ),
                            );
                          });
                        }
                      }
                      completer.complete();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Change button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Confirmar Município',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}