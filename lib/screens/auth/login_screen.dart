import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }
  _signin()
  {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user)  async {
      Navigator.pop(context);
      if(user!=null)
      {
        log("User ${user.user}");
        if((await APIs.userExists()))
        {
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>HomeScreen()));
        }
        else
        {
          await APIs.createUser().then((value){
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>HomeScreen()));
          });
        }
      
      }
    });
  }

  Future<UserCredential?>_signInWithGoogle() async {
    // Trigger the authentication flow
    try
    {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await APIs.auth.signInWithCredential(credential);
    }

  
    catch(e)
    {
      log('\n _signInWithGoogle: $e');
      Dialogs.showSnackbar(context,"Check your internet connection");
      return null;
    }
  }

  // _signOut() async
  // {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }


  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        title: Text("Welcome to Sandesh"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              duration: Duration(seconds: 1),
              top: mq.height * .15,
              width: mq.width * .5,
              right: _isAnimate ? mq.width * 0.25 : -mq.width * .5,
              child: Image.asset('images/icon.png')),
          Positioned(
            height: mq.height * .06,
            bottom: mq.height * .15,
            width: mq.width * .9,
            left: mq.width * .06,
            //  right: mq.width*.05,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(0, 255, 0, .45),
                shape: StadiumBorder(),
                elevation: 0.1,
              ),
              onPressed: () {
                _signin();
              },
              icon: Image.asset(
                'images/google.png',
                height: mq.height * .04,
              ),
              label: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "Login with",
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                  TextSpan(
                      text: " Google",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.black)),
                ]),
              ),
            ),
          )
        ],
      ),
    );
  }

}