import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  static List<String> listSchool = [];
  
  Future<void> fetchListSchool(int codMun) async {
    //final response = await http.get(Uri.parse('http::'));
    final response = await http.get(Uri.parse('http://geoter.transcolares.etg.ufmg.br:8881/appalunos/MG/3134400'));
    // http://geoter.transcolares.etg.ufmg.br:8881/appalunos/MG/3106200
    if (response.statusCode == 200){
      listSchool = json.decode(response.body).cast<String>();
    } else {
      throw Exception('Failed to load data');
    }
  }


  void getEscolas() async{
    SharedPreferences prefs = 
      await SharedPreferences.getInstance();
    
    prefs.setInt('codMun', 10);

    int ?codMun = prefs.getInt('codMun');
    if(codMun != null){
      try{
        // buscando lista de escolas no servidor do transcolar
        fetchListSchool(codMun);

      } catch(error){
        // chamar mensagem de erro

      }
    }else{
      // chamar mensagem de erro
    }
  
  }

  @override
  Widget build(BuildContext context) {
    getEscolas();
//    print(listSchool);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const SizedBox(height: 60.0),

                    const Text(
                      "Cadastrar",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Consulte a chave com o diretor da sua escola",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                          hintText: "Nome",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: Colors.purple.withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.person)),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      decoration: InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: Colors.purple.withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.email)),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      decoration: InputDecoration(
                        hintText: "Nome da Escola",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor: Colors.purple.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.password),
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      decoration: InputDecoration(
                        hintText: "Chave API",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor: Colors.purple.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.password),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
                Container(
                    padding: const EdgeInsets.only(top: 3, left: 3),

                    child: ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.lightBlue,
                      ),
                                            child: const Text(
                        "Avançar",
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                ),

                // const Center(child: Text("Or")),

                // Container(
                //   height: 45,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(25),
                //     border: Border.all(
                //       color: Colors.lightBlue,
                //     ),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.white.withOpacity(0.5),
                //         spreadRadius: 1,
                //         blurRadius: 1,
                //         offset: const Offset(0, 1), // changes position of shadow
                //       ),
                //     ],
                //   ),
                  // child: TextButton(
                  //   onPressed: () {},
                  //   child: const Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       SizedBox(
                  //         height: 30.0,
                  //         width: 30.0,
                  //         /*decoration: const BoxDecoration(
                  //           image: DecorationImage(
                  //               image:   AssetImage('assets/images/login_signup/google.png'),
                  //               fit: BoxFit.cover),
                  //           shape: BoxShape.circle,
                  //         ),*/
                  //       ),

                  //       SizedBox(width: 18),

                  //       Text("Sign In with Google",
                  //         style: TextStyle(
                  //           fontSize: 16,
                  //           color: Colors.lightBlue,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                // ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     const Text("Already have an account?"),
                //     TextButton(
                //         onPressed: () {
                //         },
                //         child: const Text("Login", style: TextStyle(color: Colors.blueAccent),)
                //     )
                //   ],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}