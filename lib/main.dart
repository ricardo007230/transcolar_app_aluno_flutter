import 'package:app_aluno/mainpage.dart';
import 'package:app_aluno/telacaptura_casa.dart';
import 'package:app_aluno/telacaptura_escola.dart';
import 'package:flutter/material.dart';
import 'package:app_aluno/splash.dart';
import 'package:app_aluno/welcome.dart';
import 'package:app_aluno/signup_page.dart';
import 'package:app_aluno/homepage.dart';
import 'package:path/path.dart';

void main(){
  runApp(MaterialApp(
    routes: {
      '/':(context) => const MainPage(),
      '/welcome': (context) => const Welcome(),
      '/signup': (context) => const SignupPage(),
      '/casa': (context) => const TelaCapturaCasa(),
      '/escola': (context) => const TelaCapturaEscola(),
      //'/homepage':(context) => const HomePage(),
    }

  )); 
}