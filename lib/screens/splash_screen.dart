import 'dart:developer';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../api/apis.dart';
import '../main.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState()
  {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000),(){
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
         
         systemNavigationBarColor: Colors.white, statusBarColor: Colors.blue));
      if(APIs.auth.currentUser !=null){
        log('\nUser:${APIs.auth.currentUser}');
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=> HomeScreen()));}
      else
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=> LoginScreen()));
    });
  }
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(children: [
        Positioned(
          top: mq.height*.15,
          right: mq.width*.25,
          width: mq.width*.5,
          child: Image.asset('images/icon.png'),
        ),

        Positioned(
          bottom: mq.height*.15,
          width: mq.width,
          child: Text("MADE IN INDIA WITH ❤️",textAlign: TextAlign.center, style: TextStyle(fontSize: 16,color: Colors.black87),),
        ),
      ]),
    );
  }
}