import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String selectedEscola = ' ';
  List<String> listSchool = [];

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

  Future<void> fetchListSchool(int codMun) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String link = 'http://geoter.transcolares.etg.ufmg.br:8881/appalunos/${prefs.getString('siglaEst')}/${prefs.getInt('codMun').toString()}?authToken=${prefs.getString('userKey')}';
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
                hintText: "Nome",
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
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.purple.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.indigo,
                  ),
              ),
            ),
            const SizedBox(height: 20),
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
                if(value!.length > 20) {
                  value = value.substring(0,20) + "...";
                }
                // handle selected value
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
                  print(selectedEscola);

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