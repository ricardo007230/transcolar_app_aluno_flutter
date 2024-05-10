import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'mundata.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeMaeController = TextEditingController();
  static String ?selectedEscola  = ' ';
  List<String> listSchool = [];

  // Para selecao de estado e municipio
  List<String>? estados;
  List<String>? municipios;
  String selectedEstado = '';
  String selectedMunicipio = '';
  String defaultEstado = '--';

  void showError(String mensagem, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

    Future<void> fetchEstados() async {
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

  Future<void> fetchListSchool(int codMun) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final munData = await MunDataDatabase.instance.fetchMunData();
    final ?codMun = munData['Belo Horizonte'];
    //String link = 'http://geoter.transcolares.etg.ufmg.br:8881/appalunos/${prefs.getString('siglaEst')}/${prefs.getInt('codMun').toString()}?authToken=${prefs.getString('userKey')}';
    String link = 'http://geoter.transcolares.etg.ufmg.br:8881/appalunos/${selectedEstado}/${prefs.getInt('codMun').toString()}?authToken=${prefs.getString('userKey')}';
    final response = await http.get(Uri.parse(link));
    if (response.statusCode == 200) {
      List<dynamic> schoolData = json.decode(response.body);
      setState(() {
        listSchool = schoolData.map((school) => school['nome'].toString()).toList();
      });
    } else {
      throw Exception('Falha para carregar as escolas, entre em contato com o suporte');
    }
  }

  void getEscolas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? codMun = prefs.getInt('codMun');
    if (codMun != null) {
      try {
        // buscando lista de escolas no servidor do transcolar
        await fetchListSchool(codMun);
      } catch (error) {
        showError(error.toString(), context);
      }
    } else {
      showError('Código de Município não encontrado.', context);
    }
  }

  @override
  void initState() {
    super.initState();
    getEscolas();
    fetchEstados();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              "Cadastrar dados pessoais",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                hintText: "Nome Completo do aluno",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.purple.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(
                  Icons.person,
                  color: Colors.indigo,
                  ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeMaeController,
              decoration: InputDecoration(
                hintText: "Nome completo da mãe",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.purple.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(
                  Icons.person,
                  color: Colors.indigo,
                  ),
              ),
            ),
            const SizedBox(height: 20),
            
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
            
            const SizedBox(height: 20),


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

            DropdownButtonFormField<String>(
              value: null,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: "Nome da Escola",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.purple.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(
                    Icons.school,
                    color: Colors.indigo,
                ),
              ),
              items: listSchool.map((school) {
                return DropdownMenuItem<String>(
                  value: school,
                  child: FittedBox(fit: BoxFit.fitHeight,child: Text(school),),
                );
              }).toList(),
              onChanged: (value) {
                selectedEscola = value;
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(top: 3, left: 3),
              child: ElevatedButton(
                onPressed: () async {

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String nome = _nomeController.text;
                  String email = _emailController.text;
                 
                  prefs.setString('nome_escola', selectedEscola.toString());
                  prefs.setString("Name", nome);
                  prefs.setString('email', email);
                  //prefs.setString('nome_escola', nome_escola);
                  Navigator.pushReplacementNamed(context, '/mainPage');
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  "Avançar",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}