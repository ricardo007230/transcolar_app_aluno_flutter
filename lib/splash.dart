import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState(){
    super.initState();
    startTimer();
  }

  startTimer(){
    //var duration = const Duration(seconds: 8);
    var duration = const Duration(seconds: 1);
    return Timer(duration , route);
  }

  route(){
    //Navigator.pushReplacementNamed(context, '/welcome');
    Navigator.pushReplacementNamed(context, '/homepage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: content(),
    );
  }

  Widget content() {
    return Center(
      child: Container(
      // child: Lottie.network(
      //   'https://lottie.host/93205153-23d0-4f53-8777-16b15e2ccbc4/kpLEX4qddI.json'
      // ),
        child: Lottie.asset('assets/images/animation.json'),
      ),
    );

  }
}