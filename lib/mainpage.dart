import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

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
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 15,),
              Expanded(child: ElevatedButton(onPressed: () {
                Navigator.pushReplacementNamed(context, "/casa");
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(244, 254, 80, 0)), 
              child: const Text("Passo 1: Registrar casa", style: TextStyle(color: Colors.black, fontSize: 20),),
                ),),
              const SizedBox(height: 15,),
              Expanded(child: ElevatedButton(onPressed: () {
                Navigator.pushReplacementNamed(context, "/escola");
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(193, 254, 80, 0)),
              child: const Text("Passo 2: Registrar escola", style: TextStyle(color: Colors.black, fontSize: 20),),)),
              const SizedBox(height: 15,),
              Expanded(child: ElevatedButton(onPressed: () {
                //Navigator.pushReplacementNamed(context, "/escola");
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(120, 254, 80, 0)),
              child: const Text("Passo 3: Enviar dados", style: TextStyle(color: Colors.black, fontSize: 20),),)),
              const SizedBox(height: 15,),
            ]),
      ),
    );
  }
}