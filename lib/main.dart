import 'package:flutter/material.dart';
import 'package:app_aluno/splash.dart';
import 'package:app_aluno/welcome.dart';
import 'package:app_aluno/signup_page.dart';

void main(){
  runApp(MaterialApp(
    routes: {
      '/':(context) => const Splash(),
      '/welcome': (context) => const Welcome(),
      '/signup': (context) => const SignupPage(),
    }

  ));
}