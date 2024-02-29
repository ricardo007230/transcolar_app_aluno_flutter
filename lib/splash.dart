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
    var duration = const Duration(seconds: 8);
    return Timer(duration , route);
  }

  route(){
    //Navigator.pushReplacementNamed(context, '/welcome');
    Navigator.pushReplacementNamed(context, '/signup');
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
      child: Lottie.network(
        'https://lottie.host/8a54f918-d848-4b6a-88ff-0798c6778815/ZSKYfVBCq4.json'
      ),
      ),
    );

  }
}